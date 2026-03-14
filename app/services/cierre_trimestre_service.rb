# app/services/cierre_trimestre_service.rb
class CierreTrimestreService
  class Error < StandardError; end
  class RecibosPendientes < Error; end
  class FacturasExistentes < Error; end
  
  attr_reader :trimestre, :anio, :numero_trimestre, :inicio, :fin
  
  def initialize(anio, numero_trimestre)
    @anio = anio.to_i
    @numero_trimestre = numero_trimestre.to_i
    @trimestre = "#{@anio}T#{@numero_trimestre}"
    @inicio = fecha_inicio_trimestre
    @fin = fecha_fin_trimestre
  end
  
  # Paso 1: Generar facturas en estado borrador
  def generar_borradores!
    verificar_precondiciones!
    
    ActiveRecord::Base.transaction do
      recibos_a_facturar.each do |recibo|
        generar_factura_para_recibo(recibo)
      end
    end
    
    {
      trimestre: trimestre,
      periodo: "#{inicio.strftime('%d/%m/%Y')} - #{fin.strftime('%d/%m/%Y')}",
      facturas_generadas: recibos_a_facturar.count,
      ventas: recibos_a_facturar.count(&:pagado?),
      abonos: recibos_a_facturar.count(&:devuelto?)
    }
  end
  
  # Paso 2: Emitir facturas (asignar números definitivos)
  def emitir!
    borradores = Factura.where(trimestre: trimestre, estado: :borrador)
    raise Error, "No hay borradores para emitir en #{trimestre}" if borradores.empty?

    count_ventas = borradores.venta.count
    count_abonos = borradores.abono.count

    ActiveRecord::Base.transaction do
      borradores.venta.order(:fecha_emision, :id).each do |factura|
        emitir_factura_venta(factura)
      end

      borradores.abono.order(:fecha_emision, :id).each do |factura|
        emitir_factura_abono(factura)
      end
    end

    {
      trimestre: trimestre,
      facturas_emitidas: count_ventas + count_abonos,
      ventas_emitidas: count_ventas,
      abonos_emitidos: count_abonos,
      ultimo_numero: Factura.where("numero REGEXP ?", "^#{anio}[0-9]{4}$").maximum(:numero)
    }
  end
  
  # Paso 3: Exportar datos para asesor/Hacienda
  def exportar
    facturas = Factura.where(trimestre: trimestre, estado: :emitida).order(:numero)
    
    {
      trimestre: trimestre,
      total_facturas: facturas.count,
      total_ventas: facturas.venta.sum(:total),
      total_abonos: facturas.abono.sum(:total),
      facturas: facturas.map { |f| datos_exportacion(f) }
    }
  end
  
  # Utilidad: deshacer borradores (si hay error antes de emitir)
  def limpiar_borradores!
    borradores = Factura.where(trimestre: trimestre, estado: :borrador)
    count = borradores.count
    
    ActiveRecord::Base.transaction do
      # Desvincular de recibos
      Recibo.where(factura_id: borradores.select(:id)).update_all(factura_id: nil)
      # Borrar facturas
      borradores.destroy_all
    end
    
    { eliminadas: count }
  end
  
  private
  
  def fecha_inicio_trimestre
    mes = ((numero_trimestre - 1) * 3) + 1
    Date.new(anio, mes, 1)
  end
  
  def fecha_fin_trimestre
    mes = numero_trimestre * 3
    Date.new(anio, mes, -1)
  end
  
  def verificar_precondiciones!
    # Verificar que no haya facturas emitidas ya para este trimestre
    emitidas = Factura.where(trimestre: trimestre, estado: :emitida).count
    raise FacturasExistentes, "Ya existen #{emitidas} facturas emitidas para #{trimestre}" if emitidas > 0
    
    # Verificar que todos los recibos estén en estado final (pagado o devuelto)
    pendientes = Recibo.serie_a_por_trimestre(inicio, fin)
                       .where.not(reciboEstado_id: [2, 3])
                       .count
    
    raise RecibosPendientes, "Hay #{pendientes} recibos pendientes de estado final" if pendientes > 0
  end
  
  def recibos_a_facturar
    @recibos_a_facturar ||= Recibo.serie_a_por_trimestre(inicio, fin).to_a
  end
  
  def generar_factura_para_recibo(recibo)
    # Crear factura de venta (siempre, incluso si luego hay abono)
    factura_venta = Factura.create!(
      numero: "BORRADOR-#{recibo.id}-V",  # temporal, se cambia al emitir
      tipo: :venta,
      estado: :borrador,
      recibo: recibo,
      fecha_emision: recibo.vencimiento.to_date,
      base_imponible: calcular_base(recibo.importe),
      iva: calcular_iva(recibo.importe),
      total: recibo.importe,
      trimestre: trimestre,
      datos_cliente_snapshot: snapshot_cliente(recibo.usuario)
    )
    
    # Vincular recibo a factura
    recibo.update!(factura_id: factura_venta.id)
    
    # Si el recibo fue devuelto, crear factura de abono pareja
    if recibo.devuelto?
      Factura.create!(
        numero: "BORRADOR-#{recibo.id}-A",  # temporal
        tipo: :abono,
        estado: :borrador,
        recibo: recibo,
        factura_origen: factura_venta,
        fecha_emision: recibo.vencimiento.to_date,
        base_imponible: -calcular_base(recibo.importe),  # negativo
        iva: -calcular_iva(recibo.importe),              # negativo
        total: -recibo.importe,                          # negativo
        trimestre: trimestre,
        motivo_abono: "Devolución de recibo bancario",
        datos_cliente_snapshot: snapshot_cliente(recibo.usuario)
      )
    end
    
    factura_venta
  end
  
  def emitir_factura_venta(factura)
    factura.update!(
      numero: Factura.generar_numero(anio),
      estado: :emitida
    )
  end
  
  def emitir_factura_abono(factura)
    factura.update!(
      numero: Factura.generar_numero(anio),
      estado: :emitida
    )
  end
  
  def calcular_base(importe)
    (importe.to_f * 100 / 121).round(2)
  end
  
  def calcular_iva(importe)
    (importe.to_f * 21 / 121).round(2)
  end
  
  def snapshot_cliente(usuario)
    {
      nombre: usuario.nombre,
      dni: usuario.dni,
      direccion: usuario.direccion,
      localidad: usuario.localidad,
      provincia: usuario.provincia,
      cp: usuario.cp,
      email: usuario.email
    }.to_json
  end
  
  def datos_exportacion(factura)
    # Parsear el JSON si es string
    cliente_data = factura.datos_cliente_snapshot
    cliente_data = JSON.parse(cliente_data) if cliente_data.is_a?(String)
    
    {
      numero: factura.numero,
      tipo: factura.tipo,
      fecha: factura.fecha_emision.strftime('%d/%m/%Y'),
      nif: cliente_data['dni'],
      nombre: cliente_data['nombre'],
      base: factura.base_imponible,
      iva: factura.iva,
      total: factura.total,
      concepto: factura.recibo&.concepto
    }
  end
end

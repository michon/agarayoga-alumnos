class FacturacionController < ApplicationController
  before_action :autorizar_facturacion
  before_action :cargar_servicio, only: [:show, :generar, :emitir, :limpiar, :exportar]

  # GET /facturacion/trimestres
  def trimestres
    @trimestres = Factura.where.not(trimestre: nil)
                        .distinct
                        .pluck(:trimestre)
                        .sort
                        .reverse
    
    # Detectar trimestres con recibos pendientes (sin facturas emitidas)
    @trimestres_pendientes = detectar_trimestres_pendientes
  end

  # GET /facturacion/2025T1
  # app/controllers/facturacion_controller.rb
  def show
    @trimestre = params[:trimestre]
    @anio, @numero = parsear_trimestre(@trimestre)
    @inicio = inicio_año = Date.current.beginning_of_year
    @fin = fin_año = Date.current.end_of_year

    # Búsqueda de FACTURAS (con filtros propios)
    @q = Factura.where(trimestre: @trimestre)
              .includes(recibo: :usuario)  # Cargar recibo y su usuario
              .ransack(params[:q])

      # Ordenación por defecto si no hay parámetro de orden
    @q.sorts = 'numero asc' if @q.sorts.empty?

    @facturas = @q.result
                .page(params[:page]).per(50)

    # Recibos del trimestre (para referencia, sin filtros complejos)
    @recibos = Recibo.where(vencimiento: @servicio.inicio..@servicio.fin)
                     .where(serie: 'A')
                     .includes(:usuario, :factura)
                     .order(:vencimiento)

    @resumen = {
      total: Factura.where(trimestre: @trimestre).count,
      emitidas: Factura.where(trimestre: @trimestre, estado: :emitida).count,
      borradores: Factura.where(trimestre: @trimestre, estado: :borrador).count,
      ventas: Factura.where(trimestre: @trimestre, tipo: :venta).sum(:total),
      abonos: Factura.where(trimestre: @trimestre, tipo: :abono).sum(:total)
    }
  end


  # POST /facturacion/2025T1/generar
  def generar
    resultado = @servicio.generar_borradores!
    
    redirect_to facturacion_trimestre_path(@trimestre),
                notice: "Generadas #{resultado[:facturas_generadas]} facturas en borrador " \
                       "(#{resultado[:ventas]} ventas, #{resultado[:abonos]} abonos)"
  rescue CierreTrimestreService::FacturasExistentes => e
    redirect_to facturacion_trimestre_path(@trimestre), alert: e.message
  rescue CierreTrimestreService::RecibosPendientes => e
    redirect_to facturacion_trimestre_path(@trimestre), alert: e.message
  end

  # POST /facturacion/2025T1/emitir
  def emitir
    resultado = @servicio.emitir!
    
    redirect_to facturacion_trimestre_path(@trimestre),
                notice: "Emitidas #{resultado[:facturas_emitidas]} facturas " \
                       "(#{resultado[:ventas_emitidas]} ventas, #{resultado[:abonos_emitidos]} abonos). " \
                       "Último número: #{resultado[:ultimo_numero]}"
  rescue CierreTrimestreService::Error => e
    redirect_to facturacion_trimestre_path(@trimestre), alert: e.message
  end

  # DELETE /facturacion/2025T1/limpiar
  def limpiar
    resultado = @servicio.limpiar_borradores!
    
    redirect_to facturacion_trimestre_path(@trimestre),
                notice: "Eliminadas #{resultado[:eliminadas]} facturas en borrador"
  end

  # GET /facturacion/2025T1/exportar
  def exportar
    datos = @servicio.exportar
    
    respond_to do |format|
      format.xlsx do
        send_data generar_excel(datos),
                  filename: "facturas_#{@trimestre}.xlsx",
                  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
      
      format.ods do
        send_data generar_ods(datos),
                  filename: "facturas_#{@trimestre}.ods",
                  type: 'application/vnd.oasis.opendocument.spreadsheet'
      end
      
      format.json { render json: datos }
    end
  end

  # app/controllers/facturacion_controller.rb
  # Añadir nuevo método para verificación AJAX o paso intermedio

  # En facturacion_controller.rb, método verificar_emision
  def verificar_emision
    @trimestre = params[:trimestre]
    @anio, @numero = parsear_trimestre(@trimestre)

    @inicio = Date.new(@anio, (@numero - 1) * 3 + 1, 1)
    @fin = @inicio.end_of_quarter

    @verificacion = calcular_verificacion(@inicio, @fin, @trimestre)

    # Precargar datos para la vista (evita N+1)
    @recibos_serie_a = Recibo.where(vencimiento: @inicio..@fin, serie: 'A')

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def pdf
    @factura = Factura.find(params[:id])

    respond_to do |format|
      format.pdf do
        pdf = FacturaPdf.new(@factura)
        send_data pdf.render,
                  filename: "factura_#{@factura.numero}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  private

  def autorizar_facturacion
    unless ComunPolicy.new(current_usuario).verFacturacion?
      render file: "public/401.html", status: :unauthorized
    end
  end

  def cargar_servicio
    @trimestre = params[:trimestre]
    @anio, @numero = parsear_trimestre(@trimestre)
    @servicio = CierreTrimestreService.new(@anio, @numero)
  rescue ArgumentError
    redirect_to facturacion_trimestres_path, alert: "Formato de trimestre inválido (ej: 2025T1)"
  end

  def parsear_trimestre(trimestre)
    if trimestre =~ /^(\d{4})T(\d)$/
      [$1.to_i, $2.to_i]
    else
      raise ArgumentError, "Formato debe ser AAAATN (ej: 2025T1)"
    end
  end

  def detectar_trimestres_pendientes
    # Trimestres que tienen recibos de serie A pero no facturas emitidas
    Recibo.where(serie: 'A', factura_id: nil)
          .where.not(vencimiento: nil)
          .distinct
          .pluck(Arel.sql("CONCAT(YEAR(vencimiento), 'T', QUARTER(vencimiento))"))
          .sort
          .reverse
  end

  def generar_excel(datos)
    headers = ['Número', 'Tipo', 'Fecha', 'NIF', 'Nombre', 'Base', 'IVA', 'Total', 'Concepto']
    
    data = datos[:facturas].map do |f|
      [
        f[:numero],
        f[:tipo],
        f[:fecha],
        f[:nif],
        f[:nombre],
        f[:base],
        f[:iva],
        f[:total],
        f[:concepto]
      ]
    end

    SpreadsheetArchitect.to_xlsx(headers: headers, data: data, escape_formulas: false)
  end

  def generar_ods(datos)
    headers = ['Número', 'Tipo', 'Fecha', 'NIF', 'Nombre', 'Base', 'IVA', 'Total', 'Concepto']
    
    data = datos[:facturas].map do |f|
      [f[:numero], f[:tipo], f[:fecha], f[:nif], f[:nombre], f[:base], f[:iva], f[:total], f[:concepto]]
    end

    SpreadsheetArchitect.to_ods(headers: headers, data: data)
  end

  # Añadir este método auxiliar en private
  def calcular_verificacion(inicio, fin, trimestre)
    recibos_serie_a = Recibo.where(vencimiento: inicio..fin, serie: 'A')

    # Desglose de recibos
    recibos_en_remesas = recibos_serie_a.joins(:remesa).count
    pagados_sin_remesa = recibos_serie_a.where(reciboEstado_id: 2, remesa_id: nil).count
    devueltos = recibos_serie_a.where(reciboEstado_id: 3).count

    # Desglose de facturas borrador
    borradores_venta = Factura.where(trimestre: trimestre, estado: :borrador, tipo: :venta).count
    borradores_abono = Factura.where(trimestre: trimestre, estado: :borrador, tipo: :abono).count

    verif = {
      # Totales
      recibos_en_remesas: recibos_en_remesas,
      pagados_sin_remesa: pagados_sin_remesa,
      devueltos: devueltos,
      facturas_borradores: borradores_venta + borradores_abono,
      borradores_venta: borradores_venta,
      borradores_abono: borradores_abono,
      facturas_emitidas: Factura.where(trimestre: trimestre, estado: :emitida).count,

      # Por estado de recibo
      recibos_pagados_sin_factura: recibos_serie_a.where(reciboEstado_id: 2, factura_id: nil).count,
      recibos_devueltos_sin_factura: recibos_serie_a.where(reciboEstado_id: 3, factura_id: nil).count,

      # Alertas
      recibos_pendientes_estado: recibos_serie_a.where(reciboEstado_id: 1).count,
      recibos_serie_a_total: recibos_serie_a.count,

      # Listas para mostrar
      problemas: []
    }

    # Detectar problemas
    remesas_sin_factura = recibos_serie_a.joins(:remesa).where(factura_id: nil).count

    if remesas_sin_factura > 0
      verif[:problemas] << {
        tipo: 'remesa_sin_factura',
        mensaje: "#{remesas_sin_factura} recibo(s) en remesas bancarias NO tienen factura asociada (ingresos no declarados a Hacienda)",
        severidad: 'error',
        cantidad: remesas_sin_factura
      }
    end

    if verif[:recibos_pendientes_estado] > 0
      verif[:problemas] << {
        tipo: 'pendientes',
        mensaje: "#{verif[:recibos_pendientes_estado]} recibo(s) de Serie A están en estado pendiente (no pagados ni devueltos)",
        severidad: 'warning',
        cantidad: verif[:recibos_pendientes_estado]
      }
    end

    verif
  end
end

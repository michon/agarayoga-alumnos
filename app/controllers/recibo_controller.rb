class ReciboController < ApplicationController
  require 'factura_recibo.rb'
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ---------------------------------------------------------------------------
  # Presenta en pantalla los recibos que no están remesados y permite
  # seleccionalos para generar una remesa
  # ---------------------------------------------------------------------------
  def remesarSeleccionar
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(remesa_id: [nil, ""])
    @seleccionarTodos = false
  end

  # ---------------------------------------------------------------------------
  # Presenta en pantalla los recibos que no están remesados y permite
  # seleccionalos para generar una remesa
  # ---------------------------------------------------------------------------
  def remesar_seleccionar_todos
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(remesa_id: [nil, ""])
    @seleccionarTodos = true
    render 'remesarSeleccionar'
  end

  def remesar_seleccionar_actual
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(remesa_id: [nil, ""])
    @seleccionarRcbs = Recibo.where(vencimiento: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month)
    @seleccionarTodos = false
    render 'remesarSeleccionar'
  end

  def remesar_seleccionar_anterior
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(remesa_id: [nil, ""])
    @seleccionarRcbs = Recibo.where(vencimiento: 1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month)
    @seleccionarTodos = false
    render 'remesarSeleccionar'
  end

  # ---------------------------------------------------------------------------
  # Crea una nueva remesa con los recibos que se le envia en rcb_ids
  # ---------------------------------------------------------------------------
  def remesarSeleccionarPost
    unless params[:rcb_ids].blank?
     @rcbs_seleccionados = Recibo.where(id: params[:rcb_ids])
     rms = Remesa.new()
     rms.nombre = "Remesa " + DateTime.now.strftime("%Y%m%d")
     rms.bic = "BCOEESMM070"
     rms.iban = "ES9630700030186209805420"
     rms.empresa = "Miguel Rodríguez López (AgâraYoga)"
     rms.save

     @rcbs_seleccionados.each do |rcb|
       RemesaRecibo.new(remesa_id: rms.id, emision: rcb.created_at, vencimiento: rcb.vencimiento, recibo_id: rcb.id).save
     end
     @rcbs_seleccionados.update_all(remesa_id: rms.id, reciboEstado_id: 2)
   end
  end

  # ---------------------------------------------------------------------------
  # Añade los recibos que se le envia en rcb_ids a la remesa rms_id
  # ---------------------------------------------------------------------------
  def remesarAnadirPost
    unless params[:rcb_ids].blank?
     @rcbs_seleccionados = Recibo.where(id: params[:rcb_ids])
     rms = Remesa.new()
     rms.nombre = "Remesa " + DateTime.now.strftime("%Y%m%d")
     rms.bic = "BCOEESMM070"
     rms.iban = "ES9630700030186209805420"
     rms.empresa = "Miguel Rodríguez López (AgâraYoga)"
     rms.save

     @rcbs_seleccionados.each do |rcb|
       RemesaRecibo.new(remesa_id: rms.id, emision: rcb.created_at, vencimiento: rcb.vencimiento, recibo_id: rcb.id).save
     end
     @rcbs_seleccionados.update_all(remesa_id: rms.id, recbiodEstado_id: 2)
   end
  end

  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  def descargarFacturacion
    unless ComunPolicy.new(current_usuario).verFacturacion?
      render :file => "public/401.html", :status => :unauthorized
    end

    fechaInicio = params[:fechaInicio].to_datetime
    fechaFin = params[:fechaFin].to_datetime

    rcb = Recibo.where(created_at: fechaInicio..fechaFin).order(:serie, :importe)

    headers=['Nombre', 'Fecha', 'Grupo', 'Pago', 'Serie']
    datos = []

    rcb.each do |rec|
      linea = []
      linea << rec.usuario.nombre
      if rec.vencimiento.blank?
        linea << I18n.l(rec.created_at, format: "%d-%m-%Y").to_s
      else
        linea << I18n.l(rec.vencimiento, format: "%d-%m-%Y").to_s
      end
      linea << rec.usuario.grupoAlumno_id
      linea << rec.importe
      linea << rec.usuario.serie
      datos << linea
    end

    file_data = SpreadsheetArchitect.to_ods(headers: headers, data: datos)
    ficNombre = 'recibos_' + I18n.l(fechaInicio, format: "%Y%m%d").to_s + '.ods'
    send_data file_data, filename: ficNombre, type: 'application/ods', diposition: 'inline'
  end

  # ---------------------------------------------------------------------------
  # marcar los recibos de serie A como facturados
  # Genera una nueva remesa
  # Añade todos los recibos seleccionados a la nueva remesa
  # ---------------------------------------------------------------------------
  def remesar()
    fechaInicio = params[:fechaInicio].to_datetime
    fechaFin = params[:fechaFin].to_datetime

    # Seleccionar los recibos de serie A como facturados
    # ------------------------------------------------
    # CAMBIO DESDE LO ANTERIOR YA QUE AHORA NO TENEMOS RELACION CON LA BASE DE DATOS DE CLIENTES EN FATURACIÓN 
    # rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id'))
    # -------------------------------------------
    rcb = Recibo.where(serie: "A")
    rcb = rcb.where(vencimiento: fechaInicio..fechaFin)
    rcb = rcb.where(reciboEstado_id: 1)

    #Crear una nueva remesa
    rms = Remesa.new
    rms.nombre = "Remesa #{DateTime.now.strftime('%Y%m%d')} "
    rms.bic = 'BCOEESMM070'
    rms.iban = 'ES9630700030186209805420'
    rms.empresa = SepaCharacterConverter.to_sepa_format('Miguel Rodríguez López (AgâraYoga)')
    rms.save

    # Añadir los recibos a la nueva remesa
    rcb.each do |r|
      rmsRcb = RemesaRecibo.new
      rmsRcb.remesa_id = rms.id
      rmsRcb.recibo_id = r.id
      rmsRcb.vencimiento = r.vencimiento
      rmsRcb.emision = DateTime.now
      rmsRcb.save
    end

    # Cambiar en el recibo el campo remesa_id
     rcb.update_all(remesa_id: rms.id)
    # Cambiar los recibos de estado a 2 (pagado)
     rcb.update_all(reciboEstado_id: '2')
    # Marcamos la bandera de remesado a cierto
     rcb.update_all(remesado: true)

    redirect_to michon_path(), alert: "Recibos remesados entre  #{I18n.l(fechaInicio, format: '%A, %d de %B de %Y')} y #{I18n.l(fechaFin, format: '%A, %d de %B de %Y')}, en total #{rcb.count}, sin incidecias "
  end

  # Generar fichero xml a partir de la remesa que se le envía.
  # POR HACER ----
  def remesarGenerarFichero(remesa)
    sdd = SEPA::DirectDebit.new(
        name: SepaCharacterConverter.to_sepa_format("Miguel Rodríguez López (AgâraYoga)"),
        bic: "BCOEESMM070",
        creditor_identifier: "ES6100133322144C"
    )
    rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    rcb.all.each do |rm|      cta =  Cuentabcocli.where(codcliente: rm.usuario.codigofacturacion)
      unless cta.first.blank?
        sdd.add_transaction(
          name: SepaCharacterConverter.to_sepa_format(rm.usuario.nombre),
          bic: cta.first.bic,
          iban: rm.usuario.iban,
          amount: rm.importe,
          currency: "EUR",
          mandate_id: "00000600000000000000000000000000001",
          mandate_date_of_signature: "31/12/2021".to_date,
          local_instrument: 'CORE',
          sequence_type: 'RCUR'
        )
      end
    end
    @xml_string = sdd.to_xml
    File.open("public/remesa.xml", "w") { |file| file.write @xml_string.join("\n") }
  end

  def numerar

  end

  def numerarPost

    # Recorrer los recibos por orden cronológico y asignar el numero de factura.
    # Grabar el conjunto de recibos.

    # 1.- Seleccionar todos los recibos entre las fechas seleccionadas cuya serie sea A y que se encuentren en estado emitido.
    fechaInicio = params[:fechaInicio].to_datetime
    fechaFin = params[:fechaFin].to_datetime

    # Seleccionar los recibos de serie A como facturados
    rcb = Recibo.where(vencimiento: fechaInicio..fechaFin)
    rcb = rcb.where(serie: 'A')

    # 2.- Comprobar que entre los recibos seleccionados no tengamos ninguno que ya tenga número de factura.

      # 3.- Buscacar el último numero de factura ????
      numFra = Recibo.order(:factura).last.factura[6..].to_i
      rcb.order(:id).each do |r|
        unless r.factura? 
          r.factura = '20250A' + (numFra += 1).to_s.rjust(6,'0')
          r.save
        end
      end
  end
 
  def yacob
      unless ComunPolicy.new(current_usuario).verFacturacion?
        render file: "public/401.html", status: :unauthorized
        return
      end

      fechaInicio = params[:fechaInicio].to_datetime
      fechaFin = params[:fechaFin].to_datetime

      rcb = Recibo.where(vencimiento: fechaInicio..fechaFin, serie: 'A').order(:factura)

      headers = ['Factura', 'Fecha', 'NIF', 'Nombre', 'Base', 'IVA', 'Domicilio', 'Provincia', 'Total']
      datos = []

      rcb.each_with_index do |rec, idx|
        row_num = idx + 2 # +1 for header, +1 because idx starts at 0
        datos << [
          rec.factura,
          (rec.vencimiento.blank? ? I18n.l(rec.created_at, format: "%d-%m-%Y").to_s : I18n.l(rec.vencimiento, format: "%d-%m-%Y").to_s),
          rec.usuario.dni,
          rec.usuario.nombre,
          "=I#{row_num}*100/121",  # Fórmula como string con =
          "=E#{row_num}*21/100",   # Fórmula como string con =º
          rec.usuario.direccion,
          rec.usuario.provincia,
          rec.importe
        ]
      end

      file_data = SpreadsheetArchitect.to_xlsx(
        headers: headers,
        data: datos,
        escape_formulas: false
      )

      ficNombre = "facturas_clientes_#{I18n.l(fechaInicio, format: "%Y%m%d")}-#{I18n.l(fechaFin, format: "%Y%m%d")}.xlsx"
      send_data file_data, 
                filename: ficNombre, 
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
                disposition: 'attachment' # ← Este cambio es clave

  end
  # listado de recibos que hay que hacer factura
  def facturar
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(reciboEstado_id: 1)
  end

  # listado de recibos que hay que hacer factura
  def facturacion
    @rcb = Recibo.all
  end

  # ---------------------------------------------------------------------------
  # Genera los recibos para la fecha seleccionada
  # ---------------------------------------------------------------------------
  def generarPost
    if params[:fecha].blank?
      fecha = DateTime.now
    else
      fecha = params[:fecha].to_datetime
    end

    # Comprobar que no existen recibos para el mes actual
    @rcbs = Recibo.where(created_at: fecha.at_beginning_of_month..fecha.at_end_of_month)

    unless @rcbs.count > 0
      alerta = "Error en proceso de Generación"

      # Obtener IDs de usuarios que NO están en grupos 7 u 8
      usuarios_excluidos = Usuario.where(grupoAlumno_id: [7, 8]).pluck(:id)

      # Filtrar usuarios con horarios y que no sean de grupos 7 u 8
      HorarioAlumno.group(:usuario_id)
                   .where.not(usuario_id: usuarios_excluidos)
                   .count.each_with_index do |alm, idx|
        generarRecibo(alm, fecha)
      end

      alerta = "Recibos generados correctamente"
    else
      alerta = "Ya existen recibos para el mes en curso"
    end

    redirect_to michon_path(), alert: alerta
  end

  # ---------------------------------------------------------------------------
  # Genera los recibos para la fecha seleccionada
  # ---------------------------------------------------------------------------
  def generar
    if params[:fecha].blank?
      fecha = DateTime.now
    else
      fecha = params[:fecha].to_datetime
    end

    #Comprobar que no existen recibos para el mes actual.
     @rcbs = Recibo.where(:created_at => fecha.at_beginning_of_month..fecha.at_end_of_month)
        unless @rcbs.count > 0 then
        HorarioAlumno.group(:usuario_id).order(:count_all).count.each_with_index do |alm, idx|
          # generarRecibo(alm,fecha)
        end
      end
      redirect_to recibo_pagos_path()
  end

  # Genera un recibo y lo graba en la tabla
  def generarRecibo(alm,fecha)
    fecha = fecha.to_datetime
    usr = Usuario.find(alm[0].to_i)
    rcb = Recibo.new()
    rcb.usuario_id = alm[0].to_i
    rcb.reciboEstado_id = 1
    rcb.concepto = "Cuota mensual de AgâraYoga " + I18n.translate(:"date.month_names", :locale => :es)[fecha.mon] + " " + fecha.year.to_s
    case alm[1].to_i
      when 1
        rcb.importe = 45
      when 2
        rcb.importe = 60
      when 3
        rcb.importe = 70
    end
    rcb.nombre = usr.nombre
    rcb.bic =  usr.bic
    rcb.iban = usr.iban
    rcb.moneda = "EUR"
    rcb.referencia = ""
    rcb.referenciaInformacion =  ""
    rcb.mandatoFecha = usr.fechafirma
    rcb.sepaTipo = "CORE"
    rcb.sepaSecuencia = "RCUR"
    rcb.batchBooking = true
    rcb.serie = usr.serie
    #rcb.remesa = ""
    rcb.pago = ""
    rcb.vencimiento = fecha
    rcb.factura = ""
    rcb.lugar = usr.lugarfirma
    rcb.save
  end

  def pagos
    @q = Recibo.ransack(params[:q])

    # Filtros por defecto (mes/año actual)
    @selected_year = params[:year] || Date.current.year
    @selected_month = params[:mes] || Date.current.month
    @selected_estado = params.dig(:q, :reciboEstado_id_eq) || 1

    @recibos_filtrados = @q.result
      .where("YEAR(vencimiento) = ?", @selected_year)
      .where("MONTH(vencimiento) = ?", @selected_month)
      .where(reciboEstado_id: @selected_estado)
      .includes(:usuario, :reciboEstado)
      .order(:vencimiento).order(serie: :desc).order(:nombre)

    @estados_recibo = ReciboEstado.all
  end


  def estado
    recibo = Recibo.find(params[:id])
    estado_anterior = recibo.reciboEstado_id
    nuevo_estado = params[:estado].to_i

    if recibo.update(reciboEstado_id: nuevo_estado)
      # Lógica de apunte en caja
      importe = calcular_importe(recibo, estado_anterior, nuevo_estado)
      crear_apunte_caja(recibo, estado_anterior, nuevo_estado, importe) if importe != 0

      # Usar filtro_params para los parámetros permitidos
      redirect_params = {
        q: filtro_params[:q],
        year: filtro_params[:year],
        mes: filtro_params[:mes],
        notice: "Recibo ##{recibo.id} de #{recibo.usuario.nombre} cambiado de " \
                "#{ReciboEstado.find(estado_anterior).nombre} a " \
                "#{recibo.reciboEstado.nombre}"
      }.compact

      redirect_to recibo_pagos_path(redirect_params)
    else
      redirect_to recibo_pagos_path(
        q: filtro_params[:q],
        year: filtro_params[:year],
        mes: filtro_params[:mes],
        alert: "Error al cambiar el estado del recibo"
      )
    end
  end


  def cambiar_estado
    unless params[:recibo_ids].blank?
      recibos = Recibo.find(params[:recibo_ids])
      nuevo_estado = params[:nuevo_estado].to_i
      
      recibos.each do |recibo|
        estado_anterior = recibo.reciboEstado_id
        recibo.reciboEstado_id = nuevo_estado
        
        if recibo.save
          # Realizar el apunte en caja
          importe = calcular_importe(recibo, estado_anterior, nuevo_estado)
          crear_apunte_caja(recibo, estado_anterior, nuevo_estado, importe) if importe != 0
        end
      end
      
      redirect_to recibo_pagos_path(q: params[:q], year: params[:year], mes: params[:mes]), 
                  notice: "Estados actualizados correctamente"
    else
      redirect_to recibo_pagos_path(q: params[:q], year: params[:year], mes: params[:mes]), 
                  alert: "No se seleccionaron recibos"
    end
  end


  def busqueda
  # Convertir parámetros a formato consistente
    @parametros_busqueda = {
      'nombre' => params[:busquedaNombre].to_s,
      'estado' => params[:busquedaEstado].to_s,
      'mes' => params[:busquedaMes].to_s
    }

    # Aplicar filtros en una sola variable sin reasignaciones
    recibos = Recibo.all
    recibos = recibos.joins(:usuario).where("usuarios.nombre LIKE ?", "%#{@parametros_busqueda['nombre']}%") if @parametros_busqueda['nombre'].present?
    recibos = recibos.where(reciboEstado_id: @parametros_busqueda['estado']) if @parametros_busqueda['estado'].present?

    if @parametros_busqueda['mes'].present? && @parametros_busqueda['mes'].to_i.between?(1, 12)
      mes = @parametros_busqueda['mes'].to_i
      fecha_inicio = Date.current.change(month: mes).beginning_of_month
      fecha_fin = fecha_inicio.end_of_month
      recibos = recibos.where(vencimiento: fecha_inicio..fecha_fin)
    end

    # Asignar FINALMENTE la variable de instancia
    @recibos_filtrados = recibos.order(:reciboEstado_id)

    Rails.logger.debug "SQL FINAL: #{@recibos_filtrados.to_sql}"
    Rails.logger.debug "Total filtrado: #{@recibos_filtrados.count}"

    @estados_recibo = ReciboEstado.all
  end

  def destroy
    Recibo.find(params[:id]).destroy
  end

  def modificar
    @rcb = params[:rcb]

    rcb = Recibo.find(params[:rcb][:id])
    unless rcb.blank?
      rcb.importe = params[:rcb][:importe]
      rcb.concepto = params[:rcb][:concepto] unless params[:rcb][:concepto].blank?
      rcb.pago = params[:rcb][:pago].to_datetime  unless params[:rcb][:pago].blank?
      rcb.save
    end
    redirect_to remesa_show_path(rcb.remesa_id)
  end

  def estado_antiguo_para_borrar
    if params[:estado].present?
      estado = params[:estado]
      rcb = Recibo.find(params[:id])
      rcb.reciboEstado_id = estado
      rcb.save

      redirect_to recibo_busqueda_path()
    end
  end

  def pagar
    rcb = Recibo.find(params[:id])
    rcb.reciboEstado_id = 2
    rcb.save
    redirect_to recibo_pagos_path()
  end


  #--------------------------------------------------------------
  # Imprime una factura a partir de un recibo en formato PDF
  #--------------------------------------------------------------
  def facturaPdf
    @rcb = Recibo.find(params[:id])
    respond_to do |format|
        format.html

        format.pdf do
          ficha = FacturaRecibo.new(@rcb)
          ficNombre = "factura_" + @rcb.usuario.nombre.sub(" ", "-")
          send_data ficha.render, filename: ficNombre, type: 'application/pdf', diposition: 'inline'
        end
    end
  end


  # NUEVAS ACCIONES CRUD
  def index
  @q = Recibo.ransack(params[:q])
  @recibos = @q.result.includes(:usuario, :reciboEstado) # ← QUITA :serie de aquí
               .order(created_at: :desc)
               .page(params[:page]).per(150)
  @series = Recibo.where.not(serie: [nil, '']).distinct.order(:serie).pluck(:serie)
end

  def new
    @recibo = Recibo.new
    @usuarios = Usuario.all.order(:nombre)
    @recibo_estados = ReciboEstado.all
  end

  def create
    @recibo = Recibo.new(recibo_params)
    
    if @recibo.save
      redirect_to gestion_recibos_path, notice: 'Recibo creado exitosamente.'
    else
      @usuarios = Usuario.all.order(:nombre)
      @recibo_estados = ReciboEstado.all
      render :new
    end
  end

  def show
    @recibo = Recibo.find(params[:id])
  end

  def edit
    @recibo = Recibo.find(params[:id])
    @usuarios = Usuario.all.order(:nombre)
    @recibo_estados = ReciboEstado.all
  end

  def update
    @recibo = Recibo.find(params[:id])
    
    if @recibo.update(recibo_params)
      redirect_to gestion_recibos_path, notice: 'Recibo actualizado exitosamente.'
    else
      @usuarios = Usuario.all.order(:nombre)
      @recibo_estados = ReciboEstado.all
      render :edit
    end
  end

  def destroy
    @recibo = Recibo.find(params[:id])
    @recibo.destroy
    redirect_to gestion_recibos_path, notice: 'Recibo eliminado exitosamente.'
  end

# .............................................................................
# Exportación de datos hacia facturaDirecta.
# .............................................................................
def exportar_facturadirecta
  # PASO 1: Verificación de permisos
  unless ComunPolicy.new(current_usuario).verFacturacion?
    render file: "public/401.html", status: :unauthorized
    return
  end

  # PASO 2: Obtención de parámetros
  begin
    fechaInicio = params[:fechaInicio].to_datetime
    fechaFin = params[:fechaFin].to_datetime
  rescue => e
    flash[:error] = "Formato de fecha incorrecto"
    redirect_back(fallback_location: root_path)
    return
  end

  # PASO 3: Selección de recibos
  rcb = Recibo.where(vencimiento: fechaInicio..fechaFin, serie: 'A')
##              .where(factura: nil)
              .includes(:usuario)
              .order(:vencimiento, :created_at)

  # Verificar si hay recibos para procesar
  if rcb.empty?
    flash[:alert] = "No hay recibos pendientes de facturar para el período seleccionado"
    redirect_back(fallback_location: root_path)
    return
  end

  # PASO 4: Asignación de números de factura
  ultima_factura = Recibo.where.not(factura: nil)
                         .where(serie: 'A')
                         .maximum(:factura)
                         .to_i

  numero_factura_actual = ultima_factura + 1
  recibos_procesados = []
  errores_asignacion = []

  rcb.each do |recibo|
    recibo.factura = numero_factura_actual.to_s
    if recibo.save
      recibos_procesados << recibo
      numero_factura_actual += 1
    else
      errores_asignacion << "Recibo #{recibo.id}: #{recibo.errors.full_messages.join(', ')}"
    end
  end

  # Si hay errores en la asignación, informar
  unless errores_asignacion.empty?
    flash[:warning] = "Algunos recibos no pudieron procesarse: #{errores_asignacion.join('; ')}"
  end

  # PASO 5: Generación archivo de facturas
  headers_facturas = [
    'Serie', 'Número factura', 'Fecha factura', 'Nombre cliente', 'NIF cliente',
    'Concepto', 'Producto', 'Importe neto', 'Tipo IVA 1', 'Base IVA 1', 
    'Total IVA 1', 'Especiales IVA 1', 'Tipo IVA 2', 'Base IVA 2', 'Total IVA 2',
    'Especiales IVA 2', 'Tipo IVA 3', 'Base IVA 3', 'Total IVA 3', 'Especiales IVA 3',
    'Importe suplidos', 'Tipo retención', 'Fecha vencimiento', 'Importe pagado',
    'Fecha pago', 'Cuenta de pago', 'Notas', 'País impuestos'
  ]

  datos_facturas = []
  clientes_exportados = Set.new

  recibos_procesados.each do |rec|
    # Cálculos financieros
    base_iva = rec.importe.to_f * 100 / 121
    total_iva = rec.importe.to_f * 21 / 121

    datos_facturas << [
      'F/25',                                   # Serie
      rec.factura,                              # Número factura
      formato_fecha_facturadirecta(rec.vencimiento.blank? ? rec.created_at : rec.vencimiento), # Fecha factura
      rec.usuario.nombre,                       # Nombre cliente
      rec.usuario.dni,                          # NIF cliente
      rec.concepto,                             # Concepto
      'Servicios de Yoga',                      # Producto
      base_iva.round(2),                        # Importe neto
      21,                                       # Tipo IVA 1
      base_iva.round(2),                        # Base IVA 1
      total_iva.round(2),                       # Total IVA 1
      '',                                       # Especiales IVA 1
      0,                                        # Tipo IVA 2
      0,                                        # Base IVA 2
      0,                                        # Total IVA 2
      '',                                       # Especiales IVA 2
      0,                                        # Tipo IVA 3
      0,                                        # Base IVA 3
      0,                                        # Total IVA 3
      '',                                       # Especiales IVA 3
      0,                                        # Importe suplidos
      0,                                        # Tipo retención
      formato_fecha_facturadirecta(rec.vencimiento), # Fecha vencimiento
      rec.pago ? rec.importe : 0,               # Importe pagado
      rec.pago ? formato_fecha_facturadirecta(rec.updated_at || rec.created_at) : '', # Fecha pago
      rec.usuario.iban,                         # Cuenta de pago
      "Exportado desde AgaraYoga - #{rec.concepto}", # Notas
      'ES'                                      # País impuestos
    ]

    clientes_exportados.add(rec.usuario)
  end

  # PASO 6: Generación archivo de clientes
  headers_clientes = [
    'Nombre o Empresa', 'Apellidos (opcional)', 'Mostrar como / Nombre comercial',
    'Correo electrónico', 'Dirección 1', 'Dirección 2', 'Teléfono 1', 'Teléfono 2',
    'Codigo postal', 'Población', 'Provincia', 'Dirección completa', 'Código de país',
    'NIF/NIE', 'Número de IVA Europeo', 'Notas', 'Identificador único externo',
    'Banco: IBAN', 'Banco: BIC/SWIFT', 'Impuestos como cliente'
  ]

  datos_clientes = []
  clientes_exportados.each do |usuario|
    datos_clientes << [
      usuario.nombre,                           # Nombre o Empresa
      '',                                       # Apellidos
      usuario.nombre,                           # Mostrar como
      usuario.email,                            # Correo electrónico
      usuario.direccion,                        # Dirección 1
      '',                                       # Dirección 2
      usuario.telefono.presence || usuario.movil, # Teléfono 1
      '',                                       # Teléfono 2
      usuario.cp,                               # Código postal
      usuario.localidad,                        # Población
      usuario.provincia,                        # Provincia
      "#{usuario.direccion}, #{usuario.localidad}", # Dirección completa
      'ES',                                     # Código de país
      usuario.dni,                              # NIF/NIE
      '',                                       # Número de IVA Europeo
      "Cliente AgaraYoga - #{usuario.codigofacturacion}", # Notas
      "CLI_AGARA_#{usuario.id}",                # Identificador único externo
      usuario.iban,                             # Banco: IBAN
      usuario.bic,                              # Banco: BIC/SWIFT
      'ind'                                     # Impuestos como cliente
    ]
  end

  # PASO 7: Creación del paquete ZIP
  begin
    zip_data = create_zip_with_files(
      facturas_data: SpreadsheetArchitect.to_xlsx(headers: headers_facturas, data: datos_facturas, escape_formulas: false),
      clientes_data: SpreadsheetArchitect.to_xlsx(headers: headers_clientes, data: datos_clientes, escape_formulas: false),
      fecha_inicio: fechaInicio,
      fecha_fin: fechaFin,
      total_facturas: datos_facturas.size,
      total_clientes: datos_clientes.size
    )

    ficNombre = "facturadirecta_export_#{I18n.l(fechaInicio, format: "%Y%m%d")}-#{I18n.l(fechaFin, format: "%Y%m%d")}.zip"
    
    # PASO 8: Entrega final
    send_data zip_data,
              filename: ficNombre,
              type: 'application/zip',
              disposition: 'attachment'

  rescue => e
    flash[:error] = "Error al generar el archivo: #{e.message}"
    redirect_back(fallback_location: root_path)
  end
end

  private

  def formato_fecha_facturadirecta(fecha)
    return '' if fecha.blank?
    fecha.strftime("%Y-%m-%d 00:00:00")
  end

  def create_zip_with_files(facturas_data:, clientes_data:, fecha_inicio:, fecha_fin:, total_facturas:, total_clientes:)
    require 'zip'

    zip_stream = Zip::OutputStream.write_buffer do |zip|
      # Archivo de facturas
      zip.put_next_entry("facturas_importacion_#{I18n.l(fecha_inicio, format: "%Y%m%d")}-#{I18n.l(fecha_fin, format: "%Y%m%d")}.xlsx")
      zip.write(facturas_data)

      # Archivo de clientes
      zip.put_next_entry("clientes_importacion_#{I18n.l(fecha_inicio, format: "%Y%m%d")}-#{I18n.l(fecha_fin, format: "%Y%m%d")}.xlsx")
      zip.write(clientes_data)

      # Archivo de resumen
      resumen = "RESUMEN DE EXPORTACIÓN FACTURADIRECTA\n"
      resumen += "=====================================\n\n"
      resumen += "Período: #{I18n.l(fecha_inicio, format: "%d/%m/%Y")} - #{I18n.l(fecha_fin, format: "%d/%m/%Y")}\n"
      resumen += "Facturas generadas: #{total_facturas}\n"
      resumen += "Clientes exportados: #{total_clientes}\n"
      resumen += "Fecha de exportación: #{I18n.l(Time.current, format: "%d/%m/%Y %H:%M")}\n"
      resumen += "Sistema origen: AgaraYoga\n\n"
      resumen += "INSTRUCCIONES:\n"
      resumen += "1. Importar primero el archivo de clientes\n"
      resumen += "2. Luego importar el archivo de facturas\n"
      resumen += "3. Verificar que no haya duplicados\n"

      zip.put_next_entry("resumen_exportacion.txt")
      zip.write(resumen)
    end

    zip_stream.rewind
    zip_stream.read
  end

    def calcular_importe(recibo, estado_anterior, nuevo_estado)
      # 1 = EMITIDO, 2 = PAGADO, 3 = DEVUELTO
      if (estado_anterior == 1 || estado_anterior == 3) && nuevo_estado == 2
        Money.new((recibo.importe * 100), 'eur') # PAGADO: importe positivo
      elsif estado_anterior == 2 && (nuevo_estado == 1 || nuevo_estado == 3)
        Money.new((recibo.importe * (-100)), 'eur') # DESHACER PAGO: importe negativo
      else
        Money.new(0, 'eur') # Otros cambios no afectan a la caja
      end
    end

    def crear_apunte_caja(recibo, estado_anterior, nuevo_estado, importe)
      estados = ReciboEstado.all.pluck(:nombre)

      apunte = Caja.new(
        fecha: DateTime.now,
        concepto: "#{recibo.usuario.nombre}. Cambio del estado del recibo #{recibo.id} " +
                  "de #{estados[estado_anterior-1]} a #{estados[nuevo_estado-1]}",
        usuario_id: recibo.usuario_id,
        importe: importe
      )

      # Calcular el total acumulado
      ultimo_apunte = Caja.last
      apunte.total = ultimo_apunte ? ultimo_apunte.total + importe : importe

      apunte.save
    end

    def filtro_params
        params.permit(
          :authenticity_token,
          :commit,
          :busquedaNombre,
          :busquedaEstado,
          :busquedaMes,
          :year,
          :mes,
          :nuevo_estado,
          date: [:busquedaMes],
          rcb_ids: [],
          recibo: [],
          rcb: [],
          usr: [],
          cuota: [],
          fechaFin: [],
          fechaInicio: [],
          q: [
            :usuario_nombre_cont,
            :reciboEstado_id_eq,
            :vencimiento_eq,
            :importe_eq,
            :id_eq,
            :s # parámetro de búsqueda global de Ransack
          ]
        ).to_h.with_indifferent_access
    end

  def recibo_params
    params.require(:recibo).permit(
      :usuario_id, :reciboEstado_id, :importe, :concepto, :vencimiento, 
      :pago, :factura, :serie, :iban, :bic, :nombre, :moneda, :referencia,
      :mandatoFecha, :sepaTipo, :sepaSecuencia, :batchBooking, :lugar, :remesa_id
    )
  end
  protected

    def configure_permitted_parameters
      filtro_params
    end
end

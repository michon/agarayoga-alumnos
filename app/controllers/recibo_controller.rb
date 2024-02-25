class ReciboController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?


  # ---------------------------------------------------------------------------
  # Presenta en pantalla los recibos que no están remesados y permite
  # seleecionalos para generar una remesa
  # ---------------------------------------------------------------------------
  def remesarSeleccionar
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(remesa_id: [nil, ""])
    @seleccionarTodos = false
  end

  # ---------------------------------------------------------------------------
  # Presenta en pantalla los recibos que no están remesados y permite
  # seleecionalos para generar una remesa
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

  # marcar los recibos de serie A como facturados
  def remesar()
    fechaInicio = params[:fechaInicio].to_datetime
    fechaFin = params[:fechaFin].to_datetime

    rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id'))
    rcb = rcb.where(vencimiento: fechaInicio..fechaFin)
    rcb = rcb.where(reciboEstado_id: 1)
    #Crear una nueva remesa
    rms = Remesa.new
    rms.nombre = "Remesa #{DateTime.now.strftime('%Y%m%d')} "
    rms.bic = 'BCOEESMM070'
    rms.iban = 'ES9630700030186209805420'
    rms.empresa = 'Miguel Rodríguez López (AgâraYoga)'
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

    redirect_to michon_path(), alert: "Recibos remesados entre  #{I18n.l(fechaInicio, format: '%A, %d de %B de %Y')} y #{I18n.l(fechaFin, format: '%A, %d de %B de %Y')}, en total #{rcb.count}, sin incidecias "
  end

  # Generar fichero xml a partir de la remesa que se le envía.
  # POR HACER ----
  def remesarGenerarFichero(remesa)
    sdd = SEPA::DirectDebit.new(
        name: "Miguel Rodríguez López (AgâraYoga)",
        bic: "BCOEESMM070",
        creditor_identifier: "ES6100133322144C"
    )
    rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    rcb.all.each do |rm|      cta =  Cuentabcocli.where(codcliente: rm.usuario.codigofacturacion)
      unless cta.first.blank?
        sdd.add_transaction(
          name: rm.usuario.nombre,
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
    #Comprobar que no existen recibos para el mes actual.
    @rcbs = Recibo.where(:created_at => fecha.at_beginning_of_month..fecha.at_end_of_month)

    unless @rcbs.count > 0 then
      alerta = "Error en proceso de Generación"
      HorarioAlumno.group(:usuario_id).count.each_with_index do |alm, idx|
        generarRecibo(alm,fecha)
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
        rcb.importe = 40
      when 2
        rcb.importe = 55
      when 3
        rcb.importe = 65
    end
    rcb.nombre = usr.nombre
    rcb.bic =   usr.bic
    rcb.iban = usr.iban
    rcb.moneda = "EUR"
    rcb.referencia = ""
    rcb.referenciaInformacion =  ""
    rcb.mandatoFecha = usr.fechafirma
    rcb.sepaTipo = "CORE"
    rcb.sepaSecuencia = "RCUR"
    rcb.batchBooking = true
    rcb.serie = usr.serie
    rcb.remesa = ""
    rcb.pago = ""
    rcb.vencimiento = fecha
    rcb.factura = ""
    rcb.lugar = usr.lugarfirma
    rcb.save
  end

  def pagos
      @parametros = ""
      @rcbs = Recibo.all
      @rcbEstado = ReciboEstado.all
  end


  #Recogemos los parametros recibo y acción y presenta los datos seleccionados
  def busqueda
      unless params[:recibo].blank?
        #seleccionamos los recibos según su estado
        case params[:accion].to_i
        when 1..3
          estado = params[:accion].to_i
          rcb = Recibo.find(params[:recibo])
          estadoAnt = rcb.reciboEstado_id
          rcb.reciboEstado_id = params[:accion].to_i
          if rcb.save
            # Realizamos el apunte en caja..
            # 1.- Calculamos el importe
            #  El importe será en negativo si:
            #     de PAGADO a EMITIDO
            #     de PAGADO a DEVUELTO
            #  El importe será positivo si:
            #     de EMITIDO a PAGADO
            #     de DEVUELTO a PAGADO
            #  El importe será 0 si:
            #     de EMITIDO a DEVUELTO
            #     de DEVUELTO a EMITIDO
            #  El
            importe = 0
            if estadoAnt == 1 || estadoAnt == 3
              importe = Money.new(0,'eur')
            end
            if estado == 2
              importe = Money.new((rcb.importe * 100), 'eur')
            end
            if estadoAnt == 2
              importe = Money.new((rcb.importe * (-100)), 'eur')
            end
            estados = ReciboEstado.all.pluck(:nombre)
            apunte = Caja.new
            apunte.fecha = DateTime.now
            apunte.concepto =  rcb.usuario.nombre + '. Cambio del estado del recibo ' + rcb.id.to_s + ' de ' + estados[estadoAnt-1] + ' a ' + estados[estado-1]
            apunte.usuario_id = rcb.usuario_id
            apunte.importe = importe
            if Caja.all.count == 0
              total = Money.new(0, 'eur')
            else
              total = Caja.all.last.total
            end
            apunte.total = total + apunte.importe
            apunte.save
          end
        end
      end

      #de los recibos seleccionados filtramos según el nombre
      @parametros = params
      @prms = params[:busquedaNombre]
      @rcbs = Recibo.all
      unless params[:busquedaNombre].blank?
        @prms = Usuario.where('nombre like ?', "%#{params[:busquedaNombre]}%").pluck(:id)
        @rcbs =  Recibo.where(usuario_id: @prms)
      end

      #de los recibos seleccionados filtramos según el estado
      unless params[:busquedaEstado].blank?
        @rcbs =  @rcbs.where(reciboEstado_id: params[:busquedaEstado])
      end

      #de los recibos seleccionados filtramos según el mes
      unless params[:busquedaMes].blank?
        if params[:busquedaMes].to_i < 12 then
          @rcbs = @rcbs.where(created_at: ((Date.current.at_beginning_of_year + (params[:busquedaMes].to_i-1).month).at_beginning_of_month)..((Date.current.at_beginning_of_year + (params[:busquedaMes].to_i-1).month).at_end_of_month + 1.day))
        end
      end

      @rcbEstado = ReciboEstado.all
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
    redirect_to michon_path()
  end

  def estado
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


  protected

  def configure_permitted_parameters
    params.permit(fecha, busquedaNombre, busquedaEstado[],busquedaMes, rcb_ids[], recibo, accion, rcb[], usr, cuota, fechaFin, fechaInicio)
  end

end

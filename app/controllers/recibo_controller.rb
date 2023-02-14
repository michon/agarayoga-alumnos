class ReciboController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def remesar
    rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).update_all(reciboEstado_id: '2')
    sdd = SEPA::DirectDebit.new(
        name: "Miguel Rodríguez López (AgâraYoga)",
        bic: "BCOEESMM070",
        creditor_identifier: "ES6100133322144C"
    )
    rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    rcb.all.each do |rm|
      cta =  Cuentabcocli.where(codcliente: rm.usuario.codigofacturacion)
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
    redirect_to michon_path(), alert: "Recibos remesados correctamente"

  end

  # listado de recibos que hay que hacer factura
  def facturar
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
  end

  # listado de recibos que hay que hacer factura
  def facturacion
    @rcb = Recibo.all
  end

  def generar
      fecha = params[:fecha].to_datetime

      #Comprobar que no existen recibos para el mes actual.
       @rcbs = Recibo.where(:created_at => fecha.at_beginning_of_month..fecha.at_end_of_month)

        unless @rcbs.count > 0 then
        HorarioAlumno.group(:usuario_id).count.each_with_index do |alm, idx|
          rcb = Recibo.new()
          rcb.usuario_id = alm[0]
          rcb.reciboEstado_id = 1
          rcb.contacto = "Cuota mensual de AgâraYoga " + I18n.translate(:"date.month_names", :locale => :es)[DateTime.now.mon] + " " + DateTime.now.year.to_s
          case alm[1]
          when 1
            rcb.importe = 35
          when 2
            rcb.importe = 50
          when 3
            rcb.importe = 60
          end
          rcb.save
        end
      end

      redirect_to recibo_pagos_path()
  end

  def pagos
      @parametros = ""
      @rcbs = Recibo.all
      @rcbEstado = ReciboEstado.all
  end

  def busqueda
      unless params[:recibo].blank?
        case params[:accion].to_i
        when 1..3
          rcb = Recibo.find(params[:recibo])
          rcb.reciboEstado_id = params[:accion].to_i
          rcb.save
        end
      end

      @parametros = params
      @prms = params[:busquedaNombre]
      @rcbs = Recibo.all
      unless params[:busquedaNombre].blank?
        @prms = Usuario.where('nombre like ?', "%#{params[:busquedaNombre]}%").pluck(:id)
        @rcbs =  Recibo.where(usuario_id: @prms)
      end

      unless params[:busquedaEstado].blank?
        @rcbs =  @rcbs.where(reciboEstado_id: params[:busquedaEstado])
      end

      unless params[:busquedaMes].blank?
        if params[:busquedaMes].to_i < 12 then
          @rcbs = @rcbs.where(created_at: ((Date.current.at_beginning_of_year + (params[:busquedaMes].to_i-1).month).at_beginning_of_month)..((Date.current.at_beginning_of_year + (params[:busquedaMes].to_i-1).month).at_end_of_month + 1.day))
        end
      end

      @rcbEstado = ReciboEstado.all
  end

  def modificar
    @rcb = params[:rcb]

    logger.debug "hola --------------------"
    logger.debug params[:rcb].to_s + "------------ todosdodo"
    logger.debug params[:rcb][:nombre] + "------------ todosdodo"
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
    rcb = Recibo.find(params[:id])
    rcb.reciboEstado_id = params[:estado]
    rcb.save
    redirect_to recibo_busqueda_path()
    end

  def pagar
    rcb = Recibo.find(params[:id])
    rcb.reciboEstado_id = 2
    rcb.save
    redirect_to recibo_pagos_path()
  end


  protected

  def configure_permitted_parameters
    params.permit(fecha, busquedaNombre, busquedaEstado[],busquedaMes, recibo, accion, rcb[])
  end

end

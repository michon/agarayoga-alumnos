class RemesaController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  require 'remesa_pdf.rb'

  def index
    @rms = Remesa.all
  end

  def show
    @remesa = Remesa.find(params[:id])
    @rcbEstado = ReciboEstado.all
    # Todos los recibos que no se han remesados - Boton añadir
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
    @rcb = @rcb.where(reciboEstado_id: 1)
    respond_to do |format|
      format.html # index.html.erb

      format.pdf do
        ficha = RemesaPdf.new(@remesa)
        ficNombre = "Remesa-" + @remesa.id.to_s + @remesa.created_at.strftime(" del %d de %B de %Y") 
        send_data ficha.render, filename: ficNombre, type: 'application/pdf', diposition: 'inline'
      end
    end
  end

  def new
  end

  def edit
  end

  #----------------------------------------------------------------------------
  # Quita el recibo de la remesa y actualiza los campos necesarios
  #----------------------------------------------------------------------------
  def quitarRecibo
    rcbId =  params[:rcb_id]
    rmsId =  params[:rms_id]
    # Borrar el recibod e la tabla RemesaREcibo
    RemesaRecibo.where(recibo_id: rcbId, remesa_id: rmsId)
    rcb= Recibo.find(rcbId)
    rcb.remesa_id = nil
    # cambiar el estado del recibo a pendiente
    rcb.reciboEstado_id= 1
    # cambiar en el recibo el campo remesa_id a null
    rcb.remesa_id = ''
    rcb.save

    redirect_to remesa_show_path(rmsId)
  end

  #----------------------------------------------------------------------------
  # Añade los recibos del array rcbsId a la remesa rmsIdº
  #----------------------------------------------------------------------------
  def eliminarRcbDeRemesa

    rcbId = params[:id]
  end

  #----------------------------------------------------------------------------
  # Añade los recibos del array rcbsId a la remesa rmsIdº
  #----------------------------------------------------------------------------
  def anhadirRcbARemesa
    rcbsId = params[:rcbs_ids]
    rmsId =  params[:rms_id]
    @rcbsId = rcbsId
    @rmsId =  params[:rms_id]


      #seleccionar todos los recibos de las ids del array que nos ha llegado
      @rcbs_seleccionados =  Recibo.where(Id: rcbsId)
      # Añadir los recibos a RemesaRecibo
       @rcbs_seleccionados.each do |rcb|
         RemesaRecibo.new(remesa_id: rmsId, emision: rcb.created_at, vencimiento: rcb.vencimiento, recibo_id: rcb.id).save
       end
       
      # Cambiar en el recibo el campo remesa_id
       @rcbs_seleccionados.update_all(remesa_id: rmsId)
      # Cambiar los recibos de estado a 2 (pagado)
       @rcbs_seleccionados.update_all(reciboEstado_id: '2')

    redirect_to remesa_show_path(rmsId)
  end

  def emitir
    @remesa = Remesa.find(params[:id])
    # First: Create the main object
    sdd = SEPA::DirectDebit.new(
      # Name of the initiating party and creditor, in German: "Auftraggeber"
      # String, max. 70 char
      name: "Miguel Rodríguez López (AgâraYoga)",

      # OPTIONAL: Business Identifier Code (SWIFT-Code) of the creditor
      # String, 8 or 11 char
      bic: 'BCOEESMM070',

      # International Bank Account Number of the creditor
      # String, max. 34 chars
      iban: 'ES9630700030186209805420',

      # Creditor Identifier, in German: Gläubiger-Identifikationsnummer
      # String, max. 35 chars
      creditor_identifier: 'ES6100133322144C'
    )

    # Second: Add transactions
    @remesa.recibos.each do |rms|
      transicion(sdd, rms)
    end

    # Last: create XML string
    xml_string = sdd.to_xml                    # Use schema pain.008.001.02
    #xml_string = sdd.to_xml('pain.008.002.02') # Use schema pain.008.002.02

      respond_to do |format|
          format.html do
            redirect_to remesa_show_path(@remesa)
          end

          format.xml do
            ficNombre = "Remesa_#{@remesa.id.to_s}.xml"
            send_data sdd.to_xml, filename: ficNombre, type: 'application/xml', diposition: 'inline'
          end
      end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:rms_id, rcbs_ids:[])
  end

  private
    
    def transicion(sdd, recibo)
      logger.debug recibo.usuario.nombre
      logger.debug sdd.last.to_json
      logger.debug recibo.bic
      logger.debug recibo.iban
      sdd.add_transaction(
        # Name of the debtor, in German: "Zahlungspflichtiger"
        # String, max. 70 char
        name: recibo.usuario.nombre,

        # OPTIONAL: Business Identifier Code (SWIFT-Code) of the debtor's account
        # String, 8 or 11 char
        bic: recibo.bic, 

        # International Bank Account Number of the debtor's account
        # String, max. 34 chars
        iban: recibo.iban,

        # Amount
        # Number with two decimal digit
        amount: recibo.importe.to_s,

        # OPTIONAL: Currency, EUR by default (ISO 4217 standard)
        # String, 3 char
        currency: 'EUR',

        # OPTIONAL: Instruction Identification, will not be submitted to the debtor
        # String, max. 35 char
        # instruction: '12345',

        # OPTIONAL: End-To-End-Identification, will be submitted to the debtor
        # String, max. 35 char
        reference: 'Fra: ' + recibo.id.to_s,

        # OPTIONAL: Unstructured remittance information, in German "Verwendungszweck"
        # String, max. 140 char
        remittance_information: recibo.concepto, 

        # Mandate identifikation, in German "Mandatsreferenz"
        # String, max. 35 char
        mandate_id: 'Recibo: ' + recibo.id.to_s,

        # Mandate Date of signature, in German "Datum, zu dem das Mandat unterschrieben wurde"
        # Date
        mandate_date_of_signature: recibo.usuario.created_at.to_date,

        # Local instrument, in German "Lastschriftart"
        # One of these strings:
        #   'CORE' ("Basis-Lastschrift")
        #   'COR1' ("Basis-Lastschrift mit verkürzter Vorlagefrist")
        #   'B2B' ("Firmen-Lastschrift")
        local_instrument: 'CORE',

        # Sequence type
        # One of these strings:
        #   'FRST' ("Erst-Lastschrift")
        #   'RCUR' ("Folge-Lastschrift")
        #   'OOFF' ("Einmalige Lastschrift")
        #   'FNAL' ("Letztmalige Lastschrift")
        sequence_type: 'RCUR',
        # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
        # Date
        #

        requested_date: Date.today + 1.day
 
        # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
        # True or False
        #batch_booking: true

      )
    end


end

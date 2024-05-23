class RemesaController < ApplicationController

  def index
    @rms = Remesa.all
  end

  def show
    @remesa = Remesa.find(params[:id])
    @rcbEstado = ReciboEstado.all
    # Todos los recibos que no se han remesados - Boton añadir
    @rcb = Recibo.where(usuario_id: Usuario.where(codigofacturacion: Cliente.where(codserie: "A").pluck("codcliente")).pluck('id')).all
  end

  def new
  end

  def edit
  end

  def emitir
    @remesa = Remesa.find(params[:id])
    # First: Create the main object
    sdd = SEPA::DirectDebit.new(
      # Name of the initiating party and creditor, in German: "Auftraggeber"
      # String, max. 70 char
      name: "Miguel Rodriguez Lopez (AgaraYoga)",

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
    transicion(sdd, @remesa.recibos.first)

    # Last: create XML string
    xml_string = sdd.to_xml                    # Use schema pain.008.001.02
    #xml_string = sdd.to_xml('pain.008.002.02') # Use schema pain.008.002.02

    Rails.logger.debug "--------------------------------------------------------------------------"
    Rails.logger.debug sdd.to_xml
    Rails.logger.debug "--------------------------------------------------------------------------"

      respond_to do |format|
          format.html do
            redirect_to remesa_show_path(@remesa)
          end

          format.xml do
            ficNombre = "Remesa #{@remesa.id.to_s}"
            send_data sdd.to_xml, filename: ficNombre, type: 'application/xml', diposition: 'inline'
          end
      end
  end

  private
    
    def transicion(sdd, recibo)
    
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
      requested_date: Date.today,

      # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
      # True or False
      #batch_booking: true

    )
    end

end

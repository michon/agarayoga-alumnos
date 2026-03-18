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
    @rcb = Recibo.where(serie: "A")
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

  def emitirAntes
    @remesa = Remesa.find(params[:id])

    ddLista = []
    @remesa.recibos.each do |rcb|
      addRcbToDdLista(ddLista, rcb)
    end

    creditor = Sepa::DirectDebitOrder::Party.new("Miguel Rodríguez López (AgâraYoga)",
                                                 "Carril Hortas 25 Bajo",
                                                 nil,
                                                 "27002",
                                                 "LUGO",
                                                 "ES",
                                                 "Miguel",
                                                 "677524729",
                                                 "contacto@agarayoga.eu")

    creditor_account = Sepa::DirectDebitOrder::BankAccount.new('ES9630700030186209805420',
                                                               'BCOEESMM070')

    sepa_identifier = Sepa::DirectDebitOrder::PrivateSepaIdentifier.new 'ES6100133322144C'

    payment = Sepa::DirectDebitOrder::CreditorPayment.new(creditor,
                                                        creditor_account,
                                                        "Remesa:" + @remesa.id.to_s ,
                                                        Date.today.to_s,
                                                        sepa_identifier,
                                                        ddLista)
    
     initiator = Sepa::DirectDebitOrder::Party.new("Miguel Rodríguez López (AgâraYoga)",
                                                 "Carril Hortas 25 Bajo",
                                                 nil,
                                                 "27002",
                                                 "LUGO",
                                                 "ES",
                                                 "Miguel",
                                                 "677524729",
                                                 "contacto@agarayoga.eu")

     order = Sepa::DirectDebitOrder::Order.new("Remesa:" + @remesa.id.to_s,
                                                initiator,
                                                [payment])

    #fi = order.to_xml  pain_008_001_version: "04"
    fi = order.to_xml  pain_008_002_version: "04"

      respond_to do |format|
          format.html do
            redirect_to remesa_show_path(@remesa)
          end

          format.xml do
            ficNombre = "Remesa_#{@remesa.id.to_s}.xml"
            send_data order.to_xml  pain_008_001_version: "04", filename: ficNombre, type: 'application/xml', diposition: 'inline'
          end
      end
  end

  def addRcbToDdLista(ddLista, rcb)
    bank_account = Sepa::DirectDebitOrder::BankAccount.new rcb.iban, rcb.bic
    debtor = Sepa::DirectDebitOrder::Party.new(rcb.nombre, rcb.usuario.direccion, nil, rcb.usuario.cp, rcb.usuario.localidad, rcb.usuario.pais, rcb.usuario.nombre, rcb.usuario.movil, rcb.usuario.email)
    mandate = Sepa::DirectDebitOrder::MandateInformation.new('Recibo: ' + rcb.id.to_s, Date.today + 1.day, 'RCUR')

    ddLista << Sepa::DirectDebitOrder::DirectDebit.new(debtor, bank_account, 'Fra: ' + rcb.id.to_s, rcb.importe, "EUR", mandate)
  end


  def emitir
    @remesa = Remesa.find(params[:id])

    # 1. Verificar si ya está bloqueada (MOVIDO ANTES del SEPA)
    if @remesa.bloqueada?
      redirect_to remesa_show_path(@remesa), alert: "Esta remesa ya fue emitida el #{@remesa.fecha_emision.strftime('%d/%m/%Y %H:%M')}"
      return
    end

    # 2. Generar XML
    sdd = SEPA::DirectDebit.new(
      name: SepaCharacterConverter.to_sepa_format("Miguel Rodríguez López (AgâraYoga)"),
      bic: 'BCOEESMM070',
      iban: 'ES9630700030186209805420',
      creditor_identifier: 'ES610013332214C'
    )

    @remesa.recibos.each do |rms|
      safe_transaction(sdd, rms)
    end

    # 3. BLOQUEAR LA REMESA - AQUÍ ESTÁ EL CÓDIGO QUE FALTABA
    @remesa.bloquear!
    Rails.logger.info "✅ Remesa ##{@remesa.id} bloqueada correctamente"

    # 4. Responder
    respond_to do |format|
      format.html { redirect_to remesa_show_path(@remesa) }

      format.xml do
        xml_content = generate_valid_xml(sdd)
        ficNombre = "remesa-#{@remesa.id}-#{@remesa.created_at.strftime("%Y%m%d")}.xml"
        send_data xml_content, 
                  filename: ficNombre, 
                  type: 'application/xml', 
                  disposition: 'attachment'  # Corregido: disposition (no diposition)
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:rms_id, rcbs_ids:[])
  end

  def desbloquear
    @remesa = Remesa.find(params[:id])

    # Solo admin puede desbloquear
    unless current_usuario&.admin? || current_usuario&.michon?
      redirect_to remesa_show_path(@remesa), alert: "No autorizado para desbloquear remesas"
      return
    end

    @remesa.desbloquear!

    # Opcional: revertir estado de recibos a pendiente si es necesario
    # @remesa.recibos.update_all(reciboEstado_id: 1, remesado: false)

    redirect_to remesa_show_path(@remesa), notice: "Remesa desbloqueada correctamente"
  end


  private
    
    # CREO QUE YA NO ES NECESARIO CUANDO FUNCIONE, QUITAR Y PROBAR.
    def transicion(sdd, recibo)
      sdd.add_transaction(
        name: SepaCharacterConverter.to_sepa_format(recibo.usuario.nombre),
        bic: recibo.bic, 
        iban: recibo.iban,
        amount: recibo.importe.to_s,
        currency: 'EUR',
        reference: 'recibo: ' + recibo.id.to_s,
        remittance_information: recibo.concepto&.unicode_normalize(:nfc) || 'Cuota AgaraYoga',
        mandate_id: 'Recibo: ' + recibo.id.to_s,
        mandate_date_of_signature: recibo.usuario.created_at.to_date,
        local_instrument: 'CORE',
        sequence_type: 'RCUR',
        requested_date: Date.today + 1.day
      )
    end

    def sanitize_for_sepa(text)
      text.to_s
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        .unicode_normalize(:nfc)
        .gsub(/[^\p{L}\p{N}\p{Sc} \.\,\-\/\(\)]/u, '') # Filtra caracteres no SEPA
    end

  def safe_transaction(sdd, recibo)
    # Validar y corregir BIC usando también el IBAN como referencia
    bic = validate_and_fix_bic(recibo.bic.to_s, recibo.iban.to_s)
    
    # Validar IBAN
    iban = recibo.iban.to_s.gsub(/\s+/, '').upcase
    
    sdd.add_transaction(
      name: SepaCharacterConverter.to_sepa_format(recibo.usuario.nombre),
      bic: bic,
      iban: iban,
      amount: recibo.importe.to_s,
      currency: 'EUR',
      reference: "Fra: #{recibo.id}",
      remittance_information: sanitize_for_sepa(recibo.concepto),
      mandate_id: "Recibo: #{recibo.id}",
      mandate_date_of_signature: recibo.usuario.created_at.to_date,
      local_instrument: 'CORE',
      sequence_type: 'RCUR',
      requested_date: Date.today + 1.day
    )
  rescue SEPA::Error => e
    Rails.logger.error "Error al añadir transacción para recibo #{recibo.id}: #{e.message}"
    nil
  end

    def validate_and_fix_bic(bic, iban = nil)
      # Limpiar y estandarizar el BIC
      bic = bic.to_s.gsub(/\s+/, '').upcase
      
      # Patrón de validación para BIC (8 u 11 caracteres alfanuméricos)
      unless bic.match?(/^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/)
        # Si no es válido y tenemos IBAN, intentar obtener BIC del banco
        if iban.present?
          country_code = iban.to_s[0..1].upcase
          bank_code = iban.to_s[4..7]
          bic = guess_bic_from_bank_code(country_code, bank_code) || bic
        end
        
        # Si sigue siendo inválido, lanzar error
        unless bic.match?(/^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/)
          raise SEPA::Error, "BIC inválido: #{bic}"
        end
      end
      
      bic
    end


    def guess_bic_from_bank_code(country_code, bank_code)
      # Mapeo de códigos de bancos españoles comunes
      spanish_banks = {
        '0049' => 'BSCHESMM',   # Santander
        '0182' => 'BBVAESMM',   # BBVA
        '0238' => 'PSTRESMM',   # Bankia
        '2080' => 'CAGLESMM',   # Abanca
        '2038' => 'CAHMESMM',   # Bankinter
        '2100' => 'CAIXESBB',   # CaixaBank
        '0073' => 'OPENESMM',   # Openbank
        '2095' => 'POPUESMM',   # Banco Sabadell
        '0081' => 'BSABESBB',   # Banco Santander (antiguo)
        '0061' => 'ESPBESMM'    # Banco Español de Crédito
      }
      
      if country_code == 'ES' && spanish_banks.key?(bank_code)
        spanish_banks[bank_code]
      end
    end
    def generate_valid_xml(sdd)
      xml = sdd.to_xml('pain.008.001.02')
      
      # Asegurar encoding válido
      xml = xml.force_encoding('UTF-8')
               .encode('UTF-8', invalid: :replace, undef: :replace)
      
      # Corregir declaración XML
      xml.sub(/<\?xml version="1\.0"\?>/, '<?xml version="1.0" encoding="UTF-8"?>')
    end

end

# app/models/recibo.rb
class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
  belongs_to :remesa, optional: true
  belongs_to :factura, optional: true
  belongs_to :recibo_origen, class_name: 'Recibo', optional: true
  has_one :recibo_abono, class_name: 'Recibo', foreign_key: 'recibo_origen_id'

  before_save :cargar_datos_bancarios_desde_usuario
  after_update :generar_recibo_abono, if: :cambio_a_devuelto_con_origen?

  validate :validar_remesa_no_bloqueada, on: :update, if: :cambio_de_estado_o_importe?

  # Ransacker para buscar por factura_id nulo (sin factura)
  ransacker :factura_id_null do |parent|
    parent.table[:factura_id]
  end

  # Scopes
  scope :sin_facturar, -> { where(factura_id: nil) }

  scope :serie_a_por_trimestre, ->(inicio, fin) {
    where(serie: 'A')
      .where(vencimiento: inicio..fin)
      .where(reciboEstado_id: [2, 3])
      .sin_facturar
      .includes(:usuario)
      .order(:vencimiento, :id)
  }

  # Ransack - definición única de atributos permitidos
  def self.ransackable_attributes(auth_object = nil)
    %w[id importe created_at updated_at nombre bic iban moneda referencia
       vencimiento factura concepto lugar remesado pago reciboEstado_id
       usuario_id remesa_id serie factura_id_null recibo_origen_id]
  end

  # Ransack - definición única de asociaciones permitidas
  def self.ransackable_associations(auth_object = nil)
    %w[usuario reciboEstado remesa factura recibo_origen recibo_abono]
  end

  # Métodos de ayuda
  def pagado?
    reciboEstado_id == 2
  end

  def devuelto?
    reciboEstado_id == 3
  end

  def listo_para_facturar?
    serie == 'A' && (pagado? || devuelto?) && factura_id.nil?
  end

  def trimestre
    return nil unless vencimiento.present?
    "#{vencimiento.year}T#{(vencimiento.month / 3.0).ceil}"
  end

  def numero_factura
    factura&.numero || factura_legacy
  end

  def asignar_factura!(factura_obj)
    update!(factura: factura_obj.numero, factura_id: factura_obj.id)
  end

  private

  def cambio_a_devuelto_con_origen?
    saved_change_to_reciboEstado_id? &&
    devuelto? &&
    recibo_origen_id.nil? &&
    recibo_abono.nil?
  end

  def generar_recibo_abono
    # Evitar recursividad si algo falla
    return if recibo_abono.present?

    Recibo.create!(
      usuario_id: usuario_id,
      importe: -importe.abs, # Asegurar negativo
      serie: serie, # Misma serie (A o B)
      reciboEstado_id: 2, # Pagado (ya resuelto)
      concepto: "Abono por devolución bancaria - Recibo ##{id}",
      vencimiento: Date.current,
      recibo_origen_id: id,
      nombre: nombre,
      bic: bic,
      iban: iban,
      moneda: moneda,
      referencia: referencia,
      mandatoFecha: mandatoFecha,
      sepaTipo: sepaTipo,
      sepaSecuencia: sepaSecuencia,
      batchBooking: batchBooking,
      lugar: lugar,
      remesa_id: nil, # No está en ninguna remesa
      pago: Date.current
    )

    Rails.logger.info "✅ Recibo de abono generado para recibo ##{id} - Importe: #{-importe}"
  rescue => e
    Rails.logger.error "❌ Error generando recibo de abono para ##{id}: #{e.message}"
    raise e # Re-lanzar para que el usuario sepa que falló
  end

  def cargar_datos_bancarios_desde_usuario
    usuario = Usuario.find_by(id: self.usuario_id)
    if usuario.present?
      self.iban ||= usuario.iban
      self.bic ||= usuario.bic
      self.nombre ||= usuario.nombre
      self.moneda ||= 'EUR'
      self.mandatoFecha ||= usuario.fechafirma
      self.sepaTipo ||= 'CORE'
      self.sepaSecuencia ||= 'RCUR'
      self.batchBooking ||= true
      self.serie ||= usuario.serie
      self.lugar ||= usuario.lugarfirma
      self.concepto ||= "Cuota mensual de AgâraYoga agosto 2025"
      self.reciboEstado_id ||= 1
    end
  end

  def validar_remesa_no_bloqueada
    return unless remesa_id.present?

    remesa = Remesa.find_by(id: remesa_id)
    return unless remesa&.bloqueada?

    errors.add(:base, "No se puede modificar - recibo en remesa emitida al banco (Remesa ##{remesa.id})")
    throw(:abort) # Evitar que se guarde
  end

  def cambio_de_estado_o_importe?
    will_save_change_to_reciboEstado_id? || will_save_change_to_importe?
  end
end

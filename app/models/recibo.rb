# app/models/recibo.rb
class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
  belongs_to :remesa, optional: true
  belongs_to :factura, optional: true

  before_save :cargar_datos_bancarios_desde_usuario

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
       usuario_id remesa_id serie factura_id_null]
  end

  # Ransack - definición única de asociaciones permitidas
  def self.ransackable_associations(auth_object = nil)
    %w[usuario reciboEstado remesa factura]
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
end

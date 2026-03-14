class Factura < ApplicationRecord
  belongs_to :recibo, optional: true
  belongs_to :factura_origen, class_name: 'Factura', optional: true
  has_one :factura_abono, class_name: 'Factura', foreign_key: 'factura_origen_id'
  
  enum tipo: { venta: 0, abono: 1 }
  enum estado: { borrador: 0, emitida: 1, anulada: 2 }
  
  validates :numero, presence: true, uniqueness: true
  validates :fecha_emision, presence: true, if: :emitida?
  
  # Scope para el último número de un año
  scope :del_anio, ->(anio) { where("numero REGEXP ?", "^#{anio}[0-9]{4}$") }

  # app/models/factura.rb
  def self.ransackable_attributes(auth_object = nil)
    ["base_imponible", "created_at", "datos_cliente_snapshot", "estado", 
     "factura_origen_id", "fecha_emision", "id", "iva", "motivo_abono", 
     "numero", "recibo_id", "tipo", "total", "trimestre", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["recibo", "factura_origen", "factura_abono"]
  end

  def self.ultimo_numero(anio)
    # Busca números con formato nuevo: 20260001 (año + 4 dígitos)
    where("numero REGEXP ?", "^#{anio}[0-9]{4}$")
      .maximum(:numero)
      &.gsub(/^#{anio}/, '')
      &.to_i || 0
  end
  
  def self.generar_numero(anio)
    siguiente = ultimo_numero(anio) + 1
    "#{anio}#{siguiente.to_s.rjust(4, '0')}"
  end
  
  def formato_nuevo?
    numero.match?(/^\d{4}\d{4}$/)  # 20260001
  end
  
  def formato_legacy?
    numero.match?(/^\d{4}\dA\d{6}$/)  # 20250A000298
  end
  
  def anio
    numero[0..3].to_i if numero.present?
  end
  
  def es_abono_de_devolucion?
    abono? && factura_origen.present?
  end
end

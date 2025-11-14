class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
  belongs_to :remesa, optional: true
  before_save :cargar_datos_bancarios_desde_usuario

  def self.ransackable_attributes(auth_object = nil)
    %w[id importe created_at updated_at nombre bic iban moneda referencia
       vencimiento factura concepto lugar remesado pago reciboEstado_id
       usuario_id remesa_id serie]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[usuario reciboEstado remesa]
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

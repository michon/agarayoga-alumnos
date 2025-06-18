class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
  belongs_to :remesa, optional: true
  before_save :cargar_datos_bancarios_desde_usuario

  private

  def cargar_datos_bancarios_desde_usuario
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
    end
  end
end

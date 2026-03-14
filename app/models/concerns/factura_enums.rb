# app/models/concerns/factura_enums.rb
module FacturaEnums
  extend ActiveSupport::Concern
  
  TIPOS = {
    venta: 0,
    abono: 1
  }.freeze
  
  ESTADOS = {
    borrador: 0,
    emitida: 1,
    anulada: 2
  }.freeze
end

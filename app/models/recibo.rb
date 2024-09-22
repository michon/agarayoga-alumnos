class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
  belongs_to :remesa, optional: true
end

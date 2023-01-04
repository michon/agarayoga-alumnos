class Recibo < ApplicationRecord
  belongs_to :usuario
  belongs_to :reciboEstado
end

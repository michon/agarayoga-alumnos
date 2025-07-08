class RemesaRecibo < ApplicationRecord
  belongs_to :recibo
  belongs_to :remesa, optional: true
end

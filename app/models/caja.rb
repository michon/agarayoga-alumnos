class Caja < ApplicationRecord
  belongs_to :usuario

  monetize :importe_cents
  monetize :total_cents


  def totalCaja
    if Caja.all.count == 0
      total = Money.new(0, 'eur')
    else
      total = Money.new(Caja.all.last.total, 'eur')
    end
  end

end

class AddDatosToRecibo < ActiveRecord::Migration[6.1]
  def change
    add_column :recibos, :pago, :datetime
    add_column :recibos, :vencimiento, :datetime
    add_column :recibos, :factura, :string
    add_column :recibos, :concepto, :string
    add_column :recibos, :lugar, :string
  end
end

class AddBancoToRecibo < ActiveRecord::Migration[6.1]
  def change
    add_column :recibos, :nombre, :string
    add_column :recibos, :bic, :string, length: 11
    add_column :recibos, :iban, :string, length: 24
    add_column :recibos, :moneda, :string, length: 3
    add_column :recibos, :referencia, :string, length: 35
    add_column :recibos, :referenciaInformacion, :string, length: 140
    add_column :recibos, :mandatoFecha, :date
    add_column :recibos, :sepaTipo, :string, length: 4 
    add_column :recibos, :sepaSecuencia, :string, lenth: 4
    add_column :recibos, :batchBooking, :boolean
  end
end

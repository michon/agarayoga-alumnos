# db/migrate/20250315_add_recibo_origen_to_recibos.rb
class AddReciboOrigenToRecibos < ActiveRecord::Migration[6.1]
  def change
    add_column :recibos, :recibo_origen_id, :integer
    add_index :recibos, :recibo_origen_id
    add_foreign_key :recibos, :recibos, column: :recibo_origen_id
  end
end

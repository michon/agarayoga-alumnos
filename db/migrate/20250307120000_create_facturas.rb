# db/migrate/20250307120000_create_facturas.rb
class CreateFacturas < ActiveRecord::Migration[6.1]
  def change
    create_table :facturas do |t|
      t.string :numero, null: false
      t.integer :tipo, null: false, default: 0
      t.integer :estado, null: false, default: 0

      # Referencias sin foreign_key constraint por ahora
      t.bigint :recibo_id, null: true
      t.bigint :factura_origen_id, null: true

      t.date :fecha_emision
      t.decimal :base_imponible, precision: 10, scale: 2
      t.decimal :iva, precision: 10, scale: 2
      t.decimal :total, precision: 10, scale: 2

      t.string :motivo_abono
      t.json :datos_cliente_snapshot

      t.string :trimestre

      t.timestamps
    end

    add_index :facturas, :numero, unique: true
    add_index :facturas, :trimestre
    add_index :facturas, [:estado, :trimestre]
    add_index :facturas, :recibo_id
    add_index :facturas, :factura_origen_id

    # No foreign keys por ahora - las añadiremos manualmente después si es necesario
  end
end

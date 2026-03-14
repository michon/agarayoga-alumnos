class AddFacturaIdToRecibos < ActiveRecord::Migration[6.1]
  def change
    # Añadir la columna sin foreign key por ahora
    add_column :recibos, :factura_id, :bigint, null: true
    
    # Índices para búsquedas rápidas
    add_index :recibos, :factura_id
    add_index :recibos, [:serie, :factura], name: 'index_recibos_on_serie_and_factura_legacy'
  end
end

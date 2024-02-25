class CreateRecibos < ActiveRecord::Migration[6.1]
  def change
    create_table :recibos do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :rebidoEstado
      t.decimal :importe

      t.timestamps
    end
  end
end

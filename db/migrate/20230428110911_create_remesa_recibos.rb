class CreateRemesaRecibos < ActiveRecord::Migration[6.1]
  def change
    create_table :remesa_recibos do |t|
      t.references :remesa, null: false, foreign_key: true
      t.datetime :vencimiento
      t.datetime :emision

      t.timestamps
    end
  end
end

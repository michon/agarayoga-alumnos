class CreateCajas < ActiveRecord::Migration[6.1]
  def change
    create_table :cajas do |t|
      t.datetime :fecha
      t.string :concepto
      #t.references :usuario, null: false, foreign_key: true
      t.money :importe
      t.money :total

      t.timestamps
    end
  end
end

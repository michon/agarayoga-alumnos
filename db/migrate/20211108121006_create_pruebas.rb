class CreatePruebas < ActiveRecord::Migration[6.1]
  def change
    create_table :pruebas do |t|
      t.references :clase, null: false, foreign_key: true
      t.string :nombre

      t.timestamps
    end
  end
end

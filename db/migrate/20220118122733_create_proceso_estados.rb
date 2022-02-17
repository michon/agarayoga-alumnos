class CreateProcesoEstados < ActiveRecord::Migration[6.1]
  def change
    create_table :proceso_estados do |t|
      t.references :proceso, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end

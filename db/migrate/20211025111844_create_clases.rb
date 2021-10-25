class CreateClases < ActiveRecord::Migration[6.1]
  def change
    create_table :clases do |t|
      t.datetime :diaHora
      t.references :instructor, null: false, foreign_key: true

      t.timestamps
    end
  end
end

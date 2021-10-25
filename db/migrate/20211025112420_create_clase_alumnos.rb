class CreateClaseAlumnos < ActiveRecord::Migration[6.1]
  def change
    create_table :clase_alumnos do |t|
      t.references :clase, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.boolean :falta
      t.datetime :noviene

      t.timestamps
    end
  end
end

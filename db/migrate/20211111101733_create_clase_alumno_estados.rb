class CreateClaseAlumnoEstados < ActiveRecord::Migration[6.1]
  def change
    create_table :clase_alumno_estados do |t|
      t.references :claseAlumno, null: false, foreign_key: true
      t.string :nombre
      t.string :color

      t.timestamps
    end
  end
end

class AddClaseAlumnoEstadoToClaseAlumno < ActiveRecord::Migration[6.1]
  def change
    add_reference :clase_alumnos, :claseAlumnoEstado, null: false, foreign_key: true
  end
end

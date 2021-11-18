class RemoveClaseAlumnoIdFromClaseAlumnoEstado < ActiveRecord::Migration[6.1]
  def change
    remove_reference :clase_alumno_estados, :claseAlumno, null: false
  end
end

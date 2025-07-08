class RemoveClaseAlumnoFromClaseAlumno < ActiveRecord::Migration[6.1]
  def change
    remove_reference :clase_alumnos, :claseAlumno, null: false
  end
end

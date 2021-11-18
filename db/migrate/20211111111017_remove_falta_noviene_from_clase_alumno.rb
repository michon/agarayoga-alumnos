class RemoveFaltaNovieneFromClaseAlumno < ActiveRecord::Migration[6.1]
  def change
    remove_column :clase_alumnos, :falta, :boolean
    remove_column :clase_alumnos, :noviene, :boolean
  end
end

class AddCodigoFacturacionToGrupoAlumno < ActiveRecord::Migration[6.1]
  def change
    add_column :grupos_alumnos, :codigoFacturacion, :string
  end
end

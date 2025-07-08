class AddNavidadToAlumnos < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :navidad, :boolean
  end
end

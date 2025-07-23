class AddNombreToJulio < ActiveRecord::Migration[6.1]
  def change
    add_column :julios, :nombre, :string
  end
end

class AddOrdenToProcesoEstado < ActiveRecord::Migration[6.1]
  def change
    add_column :proceso_estados, :orden, :integer
  end
end

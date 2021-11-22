class AddMovilToPrueba < ActiveRecord::Migration[6.1]
  def change
    add_column :pruebas, :movil, :string
  end
end

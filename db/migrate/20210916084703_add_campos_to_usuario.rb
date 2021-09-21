class AddCamposToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :dni, :string
    add_column :usuarios, :telefono, :string
    add_column :usuarios, :movil, :string
    add_column :usuarios, :direccion, :string
    add_column :usuarios, :pais, :string
    add_column :usuarios, :localidad, :string
    add_column :usuarios, :provincia, :string
    add_column :usuarios, :iban, :string
    add_column :usuarios, :lugarfirma, :string
    add_column :usuarios, :fechafirma, :date
  end
end

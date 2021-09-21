class AddCodigofacturacionToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :codigofacturacion, :string
  end
end

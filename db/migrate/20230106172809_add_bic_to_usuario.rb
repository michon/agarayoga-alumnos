class AddBicToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :bic, :string
  end
end

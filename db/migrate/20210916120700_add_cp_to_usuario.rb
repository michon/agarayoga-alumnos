class AddCpToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :cp, :string
  end
end

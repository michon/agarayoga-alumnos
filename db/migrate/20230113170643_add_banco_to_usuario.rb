class AddBancoToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :serie, :string
    add_column :usuarios, :remesa, :boolean
  end
end

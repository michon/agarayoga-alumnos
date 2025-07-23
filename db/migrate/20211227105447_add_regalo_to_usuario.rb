class AddRegaloToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :regalo, :boolean
  end
end

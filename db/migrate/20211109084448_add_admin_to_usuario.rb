class AddAdminToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :admin, :boolean, default: false
  end
end

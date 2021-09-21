class AddBajaToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :debaja, :boolean
  end
end

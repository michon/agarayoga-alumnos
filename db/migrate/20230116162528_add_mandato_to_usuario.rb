class AddMandatoToUsuario < ActiveRecord::Migration[6.1]
  def change
    add_column :usuarios, :referencia, :string
    add_column :usuarios, :tipo, :string
  end
end

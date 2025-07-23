class RenameRemesaToRemesado < ActiveRecord::Migration[6.1]
  def change
    rename_column :recibos, :remesa, :remesado
  end
end

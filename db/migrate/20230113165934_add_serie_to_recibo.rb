class AddSerieToRecibo < ActiveRecord::Migration[6.1]
  def change
    add_column :recibos, :serie, :string
    add_column :recibos, :remesa, :boolean
  end
end

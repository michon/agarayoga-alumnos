class AddColorToReciboEstado < ActiveRecord::Migration[6.1]
  def change
    add_column :recibo_estados, :color, :string
  end
end

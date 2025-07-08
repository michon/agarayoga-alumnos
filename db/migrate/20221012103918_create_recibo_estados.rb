class CreateReciboEstados < ActiveRecord::Migration[6.1]
  def change
    create_table :recibo_estados do |t|
      t.string :nombre

      t.timestamps
    end
  end
end

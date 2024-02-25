class CreateRemesas < ActiveRecord::Migration[6.1]
  def change
    create_table :remesas do |t|
      t.string :nombre
      t.string :iban
      t.string :bic
      t.string :empresa

      t.timestamps
    end
  end
end

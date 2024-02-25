class CreateClaseSolicita < ActiveRecord::Migration[6.1]
  def change
    create_table :clase_solicita do |t|
      t.references :clase, null: false, foreign_key: false 
      t.references :usuario, null: false, foreign_key: false 

      t.timestamps
    end
  end
end

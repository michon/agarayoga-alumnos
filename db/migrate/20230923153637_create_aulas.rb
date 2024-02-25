class CreateAulas < ActiveRecord::Migration[6.1]
  def change
    create_table :aulas do |t|
      t.string :nombre
      t.integer :aforo

      t.timestamps
    end
  end
end

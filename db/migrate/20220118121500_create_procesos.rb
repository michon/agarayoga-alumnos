class CreateProcesos < ActiveRecord::Migration[6.1]
  def change
    create_table :procesos do |t|
      t.string :nombre

      t.timestamps
    end
  end
end

class CreateJulios < ActiveRecord::Migration[6.1]
  def change
    create_table :julios do |t|
      t.references :usuario
      t.boolean :sem1
      t.boolean :sem2
      t.boolean :sem3
      t.boolean :sem4
      t.boolean :sem5
      t.boolean :noviene

      t.timestamps
    end
  end
end

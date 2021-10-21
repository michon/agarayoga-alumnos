class CreateHorario < ActiveRecord::Migration[6.1]
  def change
    create_table :horarios do |t|
      t.integer :diaSemana, limit: 1, inclusion: 0..6
      t.integer :hora, limit: 2, inclusion: 0..24
      t.integer :minuto, limit: 2, inclusion: 0..60
      t.references :instructor, null: false, foreign_key: true

      t.timestamps
    end
  end
end

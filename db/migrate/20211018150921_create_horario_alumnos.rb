class CreateHorarioAlumnos < ActiveRecord::Migration[6.1]
  def change
    create_table :horario_alumnos do |t|
      t.references :horario, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class AddDiaHoraToClaseAlumnos < ActiveRecord::Migration[6.1]
  def change
    add_column :clase_alumnos, :diaHora, :dateTime
    add_reference :clase_alumnos, :instructor, null: false, foreign_key: true
  end
end

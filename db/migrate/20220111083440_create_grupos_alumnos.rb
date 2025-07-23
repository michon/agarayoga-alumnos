class CreateGruposAlumnos < ActiveRecord::Migration[6.1]
  def change
    create_table :grupos_alumnos do |t|
      t.string :nombre
    end
  end
end

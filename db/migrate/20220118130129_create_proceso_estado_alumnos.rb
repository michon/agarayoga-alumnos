class CreateProcesoEstadoAlumnos < ActiveRecord::Migration[6.1]
  def change
    create_table :proceso_estado_alumnos do |t|
      t.references :Usuario, null: false, foreign_key: true
      t.references :procesoEstado, null: false, foreign_key: true

      t.timestamps
    end
  end
end

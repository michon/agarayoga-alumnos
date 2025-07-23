class AddAulaToClase < ActiveRecord::Migration[6.1]
  def change
    add_reference :clases, :aula, null: false, foreign_key: true
  end
end

class AddUsuarioToInstructor < ActiveRecord::Migration[6.1]
  def change
    add_reference :instructores, :usuario, null: false, foreign_key: true
  end
end

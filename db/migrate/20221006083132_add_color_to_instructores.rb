class AddColorToInstructores < ActiveRecord::Migration[6.1]
  def change
    add_column :instructores, :color, :string
  end
end

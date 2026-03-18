# db/migrate/20250315_add_bloqueo_to_remesas.rb
class AddBloqueoToRemesas < ActiveRecord::Migration[6.1]
  def change
    add_column :remesas, :bloqueada, :boolean, default: false
    add_column :remesas, :fecha_emision, :datetime
  end
end

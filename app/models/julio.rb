class Julio < ApplicationRecord
  belongs_to :usuario

  validate :exclusive_selection

  def self.ransackable_attributes(auth_object = nil)
    [ "nombre" ]
  end  

  private

  def exclusive_selection
    if noviene && [sem1, sem2, sem3, sem4, sem5].any?
      errors.add(:base, "No puedes seleccionar semanas si has marcado que no vendrás")
    elsif !noviene && [sem1, sem2, sem3, sem4, sem5].none?
      errors.add(:base, "Por favor selecciona al menos una semana o marca que no vendrás")
    end
  end


end


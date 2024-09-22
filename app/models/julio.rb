class Julio < ApplicationRecord
  belongs_to :usuario

  def self.ransackable_attributes(auth_object = nil)
    [ "nombre" ]
  end  

end


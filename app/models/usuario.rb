class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def ibanImpreso
      ibanImp = ""
      (self.iban.length/4).times do |i|
        ibanImp <<  self.iban[(i*4)..(i*4)+3] + " "
      end
      ibanImp
  end
end

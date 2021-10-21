class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :horarioAlumno
  has_one_attached :image, :dependent => :destroy

  scope :activo, -> {where(debaja: false)}
  scope :inactivos, -> {where(debaja: true)}

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

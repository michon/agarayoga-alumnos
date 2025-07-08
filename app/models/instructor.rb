class Instructor < ApplicationRecord
  has_one_attached :image, :dependent => :destroy
  has_one :usuario
  has_many :clase
  has_many :horario
end

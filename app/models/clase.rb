class Clase < ApplicationRecord
  belongs_to :instructor
  has_many :claseAlumno, dependent: :destroy
  has_many :usuario, through: :claseAlumno
end

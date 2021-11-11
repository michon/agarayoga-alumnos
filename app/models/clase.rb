class Clase < ApplicationRecord
  belongs_to :instructor
  has_many :pruebas
  has_many :claseAlumno, dependent: :destroy
  has_many :usuario, through: :claseAlumno


end

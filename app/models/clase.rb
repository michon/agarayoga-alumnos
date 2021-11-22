class Clase < ApplicationRecord
  belongs_to :instructor
  has_many :pruebas
  has_many :claseAlumno, dependent: :destroy
  has_many :usuario, through: :claseAlumno


  def asistentes
      self.usuario.all.count + self.pruebas.all.count
  end
end

class Clase < ApplicationRecord
  belongs_to :instructor
  belongs_to :aula
  has_many :pruebas
  has_many :claseAlumno, dependent: :destroy
  has_many :claseSolicitum, dependent: :destroy
  has_many :usuario, through: :claseAlumno


  def asistentes
      self.claseAlumno.where("claseAlumnoEstado_id < 3").count + self.pruebas.all.count - self.usuario.where(grupoAlumno_id: 5).count
  end
end

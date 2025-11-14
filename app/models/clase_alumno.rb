class ClaseAlumno < ApplicationRecord
  belongs_to :clase
  belongs_to :usuario
  belongs_to :instructor
  belongs_to :claseAlumnoEstado

  scope :futuras, -> { where('clase_alumnos.diaHora >= ?', DateTime.now) }
  scope :activas_por_usuario, ->(usuario_id) {
    where(usuario_id: usuario_id, claseAlumnoEstado_id: 1)
  }
end

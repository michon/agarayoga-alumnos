class ClaseAlumno < ApplicationRecord
  belongs_to :clase
  belongs_to :usuario
  belongs_to :instructor
  belongs_to :claseAlumnoEstado
end

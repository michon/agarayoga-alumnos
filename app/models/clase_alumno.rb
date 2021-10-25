class ClaseAlumno < ApplicationRecord
  belongs_to :clase
  belongs_to :usuario
end

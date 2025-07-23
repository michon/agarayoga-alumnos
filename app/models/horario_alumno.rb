class HorarioAlumno < ApplicationRecord
  belongs_to :horario
  belongs_to :usuario
end

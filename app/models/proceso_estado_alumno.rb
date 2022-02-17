class ProcesoEstadoAlumno < ApplicationRecord
  belongs_to :Usuario
  belongs_to :procesoEstado
end

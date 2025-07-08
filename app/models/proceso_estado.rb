class ProcesoEstado < ApplicationRecord
  belongs_to :proceso
  has_many :procesoEstadoAlumno
end

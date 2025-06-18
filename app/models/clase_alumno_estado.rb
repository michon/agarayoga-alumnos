class ClaseAlumnoEstado < ApplicationRecord
  enum claseAlumnoEstado_id: { viene: 1, asistio: 2, aviso: 3, falto: 4}
end

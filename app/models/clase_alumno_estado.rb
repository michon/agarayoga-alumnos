class ClaseAlumnoEstado < ApplicationRecord
  has_many :clase_alumnos, foreign_key: 'claseAlumnoEstado_id'
   enum claseAlumnoEstado_id: {
    viene: 1,
    asistio: 2,
    aviso: 3,
    falto: 4,
    cambio: 5  # NUEVO ESTADO
  }
end

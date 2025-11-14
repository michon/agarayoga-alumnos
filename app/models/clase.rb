class Clase < ApplicationRecord
  belongs_to :instructor
  belongs_to :aula
  has_many :pruebas
  has_many :claseAlumno, dependent: :destroy
  has_many :claseSolicitum, dependent: :destroy
  has_many :usuario, through: :claseAlumno

  scope :futuras, -> { where('clases.diaHora >= ?', DateTime.now) }
  scope :activas, -> { where(activa: true) }
  scope :con_clase_alumno_activa, ->(usuario_id) {
    joins(:claseAlumno)
      .merge(ClaseAlumno.futuras.activas_por_usuario(usuario_id))
  }

  def alumnos_en_clase
      self.claseAlumno
  end

  def asistentes
      self.claseAlumno.where("claseAlumnoEstado_id < 3").count + self.pruebas.all.count - self.usuario.where(grupoAlumno_id: 5).count
  end

  def diasemana_enum
        ['DO','LU','MA','MI','JU','VI','SA']
  end

  def meses_enum
        ['ENE','FEB','MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC']
  end

  def clase_humano_instructor
    "#{diasemana_enum[self.diaHora.wday]} #{self.diaHora.strftime('%d')} #{meses_enum[self.diaHora.month-1]}#{self.diaHora.strftime(' - %H:%M')}#{self.instructor.nombre}"
  end

  def clase_humano
    "#{diasemana_enum[self.diaHora.wday]} #{self.diaHora.strftime('%d')} #{meses_enum[self.diaHora.month-1]}#{self.diaHora.strftime(' - %H:%M')}"
  end

end

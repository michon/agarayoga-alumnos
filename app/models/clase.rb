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

  def diasemana_enum
        ['DO','LU','MA','MI','JU','VI','SA']
  end

  def meses_enum
        ['ENE','FEB','MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC']
  end

  def clase_humano
    "#{diasemana_enum[self.diaHora.wday]} #{self.diaHora.strftime('%d')} #{meses_enum[self.diaHora.month]}#{self.diaHora.strftime(' - %H:%M')}"
  end

end

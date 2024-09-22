class Horario < ActiveRecord::Base

    belongs_to :instructor
    belongs_to :aula

    has_many :horarioAlumno, dependent: :destroy
    has_many :usuario, through: :horarioAlumno


    validates :hora, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
    validates :minuto, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60 }


    def alumnosTotal
        HorarioAlumno.select("distinct usuario_id")
    end

    def diasemana_enum
        [['domingo','0'], ['lunes','1'], ['martes','2'], ['miércoles','3'], ['jueves','4'], ['viernes','5'], ['sábado','6']]
    end

    def hora_humano
        self.hora.to_s + ':' + self.minuto.to_s.rjust(2,'0')
    end

    def clase_humano
        diasemana_enum[self.diaSemana][0].capitalize + ' ' + self.hora.to_s.rjust(2,'0') + ':' + self.minuto.to_s.rjust(2,'0')
    end

    def dia_humano
        diasemana_enum[self.diaSemana][0]
    end

  def horario_label_method
     semana = ['domingo','lunes','martes','miércoles','jueves','viernes','sábado']
     unless self.diaSemana.blank?
       diasemana_enum[self.diaSemana][0].capitalize + ' ' + self.hora.to_s.rjust(2,'0') + ':' + self.minuto.to_s.rjust(2,'0') + ' (' + self.instructor.nombre + ')'
     end
     
  end
end

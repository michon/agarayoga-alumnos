class Horario < ActiveRecord::Base

    belongs_to :instructor
    has_many :horarioAlumno
    has_many :usuario, through: :horarioAlumno


    validates :hora, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 } 
    validates :minuto, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60 } 

    

    def diasemana_enum 
        [['domingo','0'], ['lunes','1'], ['martes','2'], ['miércoles','3'], ['jueves','4'], ['viernes'],'5', ['sábado'],'6']
    end

    def clase_humano 
        diasemana_enum[self.diaSemana][0] + ' ' + self.hora.to_s + ':' + self.minuto.to_s
    end

    def dia_humano 
        diasemana_enum[self.diaSemana][0]
    end

end 


class Horario < ActiveRecord::Base

    belongs_to :instructor
    has_many :horarioAlumno, dependent: :destroy
    has_many :usuario, through: :horarioAlumno


    validates :hora, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 } 
    validates :minuto, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60 } 

    

    def diasemana_enum 
        [['domingo','0'], ['lunes','1'], ['martes','2'], ['miércoles','3'], ['jueves','4'], ['viernes','5'], ['sábado','6']]
    end

    def clase_humano 
        diasemana_enum[self.diaSemana][0] + ' ' + self.hora.to_s + ':' + self.minuto.to_s
    end

    def dia_humano 
        diasemana_enum[self.diaSemana][0]
    end

    #crea las clases para una fecha especificada a partir de la plantilla del
    #horario.
    def crearClases(fecha)
        Horario.all.each do |h|
            fechaClase = fecha - (fecha.day - h.diaSemana).days
            fechaClase.change(hour: h.hora, min: h.minuto)
            cl = Clase.new(diaHora: fechaClase, instructor: h.instructor)
            h.horarioAlumno.each do |ha|
               cl.claseAlumno.new(usuario: ha.usuario) 
            end
            cl.save
        end
    end
end 

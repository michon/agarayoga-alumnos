
class HorarioClase

    def initialize

    end

    #crea las clases para una fecha especificada a partir de la plantilla del
    #horario.
    def crearClases(fecha)
        Horario.all.each do |h|
            fechaClase = fecha - (fecha.wday - h.diaSemana).days
            fechaClase = fechaClase.change(hour: h.hora, min: h.minuto)
            cl = Clase.new(diaHora: fechaClase, instructor: h.instructor)
            h.horarioAlumno.each do |ha|
               cl.claseAlumno.new(usuario: ha.usuario, claseAlumnoEstado_id: 1, diaHora: fechaClase, instructor_id: h.instructor.id)
            end
            cl.save
        end
    end

end

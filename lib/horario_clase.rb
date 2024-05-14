
class HorarioClase

    def initialize

    end

    #crea las clases para una fecha especificada a partir de la plantilla del
    #horario.
    def crearClases(fecha)
        Horario.all.each do |h|
            fechaClase = fecha - (fecha.wday - h.diaSemana).days
            fechaClase = fechaClase.change(hour: h.hora, min: h.minuto)
            # Controlamos que no exista la misma clase.
            Rails.logger.debug "----------------------------------------------------------------------------------"
            Rails.logger.debug "fecha: #{fechaClase} - instructor: #{h.instructor_id} - aula: #{h.aula_id}"
            Rails.logger.debug "----------------------------------------------------------------------------------"
            if Clase.find_by( diaHora: fechaClase, instructor_id: h.instructor.id, aula_id: h.aula.id).nil?
              cl = Clase.new(diaHora: fechaClase, instructor: h.instructor, aula: h.aula)
              h.horarioAlumno.each do |ha|
                 cl.claseAlumno.new(usuario: ha.usuario, claseAlumnoEstado_id: 1, diaHora: fechaClase, instructor_id: h.instructor.id)
              end
              cl.save
            else
              Rails.logger.debug "------ no crea la clase -------"
              Rails.logger.debug "------ Clase.find_by( diaHora: #{fechaClase}, instructor_id: #{h.instructor.id}, aula_id: #{h.aula.id}).nil?"
            end
        end
    end

end


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
      if Clase.find_by( diaHora: fechaClase, instructor_id: h.instructor.id, aula_id: h.aula.id).nil?
        cl = Clase.new(diaHora: fechaClase, instructor: h.instructor, aula: h.aula, activa: true)
        h.horarioAlumno.each do |ha|
           cl.claseAlumno.new(usuario: ha.usuario, claseAlumnoEstado_id: 1, diaHora: fechaClase, instructor_id: h.instructor.id)
        end
        cl.save
      end
    end
    end


def crearJulio(fecha)
  Horario.includes(:horarioAlumno, :instructor, :aula).each do |h|
    next if h.horarioAlumno.blank?

    fechaClase = fecha - (fecha.wday - h.diaSemana).days
    fechaClase = fechaClase.change(hour: h.hora, min: h.minuto)

    unless Clase.exists?(diaHora: fechaClase, instructor_id: h.instructor.id, aula_id: h.aula.id)
      cl = Clase.new(diaHora: fechaClase, instructor: h.instructor, aula: h.aula)

      h.horarioAlumno.each do |ha|
        # Usamos find_by en lugar de where para obtener un solo registro

      jl = Julio.find_by(usuario_id: ha.usuario_id)
        next unless jl  # Saltar si no existe registro en julio

        esta = case fechaClase.cweek
               when 27 then jl.sem1
               when 28 then jl.sem2
               when 29 then jl.sem3
               when 30 then jl.sem4
               when 31 then jl.sem5
               else false
               end

        if esta
          cl.claseAlumno.build(
            usuario: ha.usuario,
            claseAlumnoEstado_id: 1,
            diaHora: fechaClase,
            instructor_id: h.instructor.id
          )
        end
      end
      cl.save
    end
  end

end



    #crea las clases para una fecha especificada a partir de la plantilla del
    #horario.
end

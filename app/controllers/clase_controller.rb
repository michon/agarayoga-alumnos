class ClaseController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def semana()
      # horarioSemana es un hash que tiene una entrada por cada dia (key) que
      # tenemos en el horario, cada una de estas entradas  contendrá otro hash
      # cuya clave será la hora de la clase y el contenido un registro de hoario (una clase).

      @fecha = params[:fecha].to_datetime
      diasSemana = Clase.select("date_format(diaHora, '%w') as dia").where(:diaHora => @fecha.beginning_of_week..@fecha.end_of_week).order(:dia).distinct
      horasDistintas = Clase.select("date_format(diaHora, '%H:%i') as hora").where(:diaHora => @fecha.beginning_of_week..@fecha.end_of_week).order(:hora).distinct

      @horarioSemana = Hash.new()
      for idx in diasSemana.first.dia.to_i..diasSemana.last.dia.to_i do #generamos todos los dias
          @horarioSemana.store(idx, Hash.new)
          horasDistintas.each do |h|
              horaClase = h.hora
              #montar un date time para esta @fecha y hora
              fechaCl  = @fecha.beginning_of_week.days_since(idx-1)
              fechaCl = fechaCl.change(hour: h.hora[0..1].to_i, min: h.hora[3..4].to_i)
              cl = Clase.where(diaHora: fechaCl).first
              @horarioSemana[idx].store(h.hora, cl)
          end
      end
  end

  # Presenta las clases proyectadas para hoy
  def actual
        params[:fecha] = DateTime.now
        redirect_to dia
  end

  # Presenta las clases proyectadas para un día
  def dia
    fecha = params[:fecha].to_datetime
    @fecha = params[:fecha].to_datetime
    @clasesHoy = Clase.where(:diaHora => fecha.beginning_of_day..fecha.end_of_day).order(:diaHora)
    @alumnosActivos = Usuario.where(debaja: false)
    @estados = ClaseAlumnoEstado.all
  end

  # Método POST
  # Recibe una fecha y envía a la presentación semanal
  def seleccion
      fecha = params[:fecha]
      redirect_to clase_semana_url(fecha)
  end

  # Método POST
  # Recibe una id ClaseAlumno_id y lo borra
  def bajaPrueba
      Prueba.find(params[:prueba_id]).destroy
      redirect_to clase_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe un nombre, movil y id de la clase y cursa un alta
  def altaPrueba
      fecha = params[:fecha]

      Prueba.new(nombre: params[:nombre], movil: params[:movil], clase_id: params[:clase_id]).save
      redirect_to clase_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe una id ClaseAlumno_id y lo borra
  def bajaAlumnos
      ClaseAlumno.find(params[:clase_alumno_id]).destroy
      redirect_to clase_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe una Modelo ClaseAlumno y lo da de alta en la tabla
  def altaAlumno
      clAlmParam = params[:clase_alumno]

      fecha = params[:fecha]

      clAlm = ClaseAlumno.new
      clAlm.usuario_id = clAlmParam[:usuario_id]
      clAlm.clase_id = clAlmParam[:clase_id]
      clAlm.claseAlumnoEstado_id = clAlmParam[:claseAlumnoEstado_id]
      clAlm.diaHora = Clase.find(clAlmParam[:clase_id]).diaHora 
      clAlm.instructor_id = Clase.find(clAlmParam[:clase_id]).instructor_id 
      clAlm.save

      redirect_to clase_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe una fecha y envía a la presentación de ese día
  def seleccionDia
      fecha = params[:fecha]
      redirect_to clase_dia_url(fecha)
  end

  # Método POST entrada de datos del formulario semana
  # Recibe una lista de alumnos y una acción a realizar que debe corresponder
  # con la tabla claseAlumnoEstado.
  def estado
    accion = 0
    params.each do |p|
        if p[0].start_with?('accion') then
            accion = p[1]
        end
     end

     fijarEstado(params[:alumnos_ids],accion.to_i)

     redirect_back(fallback_location: clase_semana_url(Date.today))
  end

  protected

  #Fija el valor de estado en la tabla ClaseAlumnoEstado recibe un array con los
  #alumnos a los que se les debe aplicar el estado y un estado a aplicar.
  def fijarEstado(alumnos,estado)
      alumnos.each do |alm|
          cl = ClaseAlumno.find(alm)
          cl.claseAlumnoEstado_id = estado
          cl.save
      end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:fecha, accion, alumnos_ids:[])
  end

end

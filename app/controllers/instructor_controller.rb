class InstructorController < ApplicationController
  def index
      @fechaHoy = Date.today
      @instructores = Instructor.all
      @clases_mes = Clase.where(instructor_id: current_usuario.instructor.id)
                     .where(diaHora: @fechaHoy.beginning_of_month..@fechaHoy.end_of_month)
                     .order(:diaHora)
  end

  def show
      unless InstructorPolicy.new(current_usuario).verShow?
        render :file => "public/401.html", :status => :unauthorized
      end
        @id = params[:id]
        @fecha = "01/02/2022".to_datetime
        @fecha = params[:fecha].to_datetime

        @instructor = Instructor.find(params[:id])
        @clases = Clase.where(instructor_id: @id).where(diaHora: @fecha.beginning_of_month..@fecha.end_of_month).order(:diaHora)
        @total = 0

        @recibos = Reciboscli.all
        @Usuario = Usuario

       #Deberia comprobar la tabla reciboscli de la facturación para ver si no tiene recibos pendientes.
       #En caso afirmativo, se cuenta para pagar a Raquel
       #En caso negativo no.
       #Luego el proceso normal si tiene menos de 7 12 e si son 7 u 8  18 y si mp 20

       @clases.each do |cl|
         if cl.claseAlumno.count == 0
                 @total = @total
             elsif cl.claseAlumno.count < 7
                 @total = @total + 20
             elsif cl.claseAlumno.count < 9
                 @total = @total + 20
             else
                @total  = @total + 20
         end
       end

       if @clases.count < 1 then
         redirect_to instructor_index_path(), alert: "Este instructor aún no ha dado clases"
       end
  end
  #Presenta las clases del día para el instructor que esté logueado.
  def dianuevo
    @fecha = params[:fecha] ? Date.parse(params[:fecha]) : Date.today
    @instructor = current_usuario.instructor
    @clasesHoy = Clase.where(instructor: @instructor)
                     .where("DATE(diaHora) = ?", @fecha)
                     .order(:diaHora)
                     .includes(:instructor,
                              :claseAlumno => [:usuario, :claseAlumnoEstado],
                              :claseSolicitum => [:usuario]) # Incluir solicitudes
    @estados = ClaseAlumnoEstado.all
  end
  #Cambia el estado del alumno interactivamente.
  #
def update_estado_alumno
  @clase_alumnos = ClaseAlumno.where(id: params[:alumno_id])
  success = true
  errors = []

  # Actualizar cada registro individualmente
  @clase_alumnos.each do |alumno|
    unless alumno.update(claseAlumnoEstado_id: params[:nuevo_estado_id])
      success = false
      errors << "Error actualizando alumno #{alumno.id}: #{alumno.errors.full_messages.join(', ')}"
    end
  end

  # Respuesta JSON
  respond_to do |format|
    if success
      format.json { render json: { 
        success: true, 
        message: "Estados actualizados correctamente",
        updates: @clase_alumnos.map { |a| { id: a.id, estado_id: a.claseAlumnoEstado_id } }
      } }
    else
      format.json { render json: { 
        success: false, 
        errors: errors 
      }, status: :unprocessable_entity }
    end
  end
end

# Presenta las clases del día para el instructor que esté logueado.
  def dia
      unless InstructorPolicy.new(current_usuario).verDia?
        render :file => "public/401.html", :status => :unauthorized
      end

    @fecha = params[:fecha].to_datetime
    @clasesHoy = Clase.where(:diaHora => @fecha.beginning_of_day..@fecha.end_of_day, instructor: current_usuario.instructor_id).order(:diaHora)
    if @clasesHoy.blank?
      clase_vacia
    end
    @alumnosActivos = Usuario.where(debaja: false)
    @estados = ClaseAlumnoEstado.all

  end


  # app/controllers/clases_controller.rb
  def agenda
    if InstructorPolicy.new(current_usuario).verDia?
      @clases = Clase.where(instructor_id: current_usuario.instructor_id)
                     .where(diaHora: DateTime.now..)
                     .order(:diaHora)
    else
      redirect_to root_path, alert: "No tienes permiso para ver esta agenda"
    end
  end

  # Método POST
  # Recibe una id ClaseAlumno_id y lo borra
  def bajaPrueba
      Prueba.find(params[:prueba_id]).destroy
      redirect_to instructor_dianuevo_url(params[:fecha])
  end

  # Método POST
  # Recibe un nombre, movil y id de la clase y cursa un alta
  def altaPrueba
    if Prueba.new(nombre: params[:nombre], movil: params[:movil], clase_id: params[:clase_id]).save
      redirect_back fallback_location: root_path, notice: 'Prueba agregada'
    else
      redirect_back fallback_location: root_path, alert: 'Error al agregar prueba'
    end
  end
  # Método POST
  # Recibe una fecha y envía a la presentación de ese día
  def seleccionDia
      fecha = params[:fecha]
      redirect_to instructor_dia_url(fecha)
  end

  # Método POST
  # Recibe una id ClaseAlumno_id y lo borra
  def bajaAlumnos
      ClaseAlumno.find(params[:clase_alumno_id]).destroy
      redirect_to instructor_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe una Modelo ClaseAlumno y lo da de alta en la tabla
  def altaAlumno
  # Versión segura que maneja parámetros nulos
    usuario_id = params[:usuario_id] || params.dig(:clase_alumno, :usuario_id)
    clase_id = params[:clase_id] || params.dig(:clase_alumno, :clase_id)

    # Crear registro con manejo de errores
    begin
      clAlm = ClaseAlumno.new(
        usuario_id: usuario_id,
        clase_id: clase_id,
        claseAlumnoEstado_id: 1, # Estado por defecto, ajusta según tu lógica
        diaHora: Clase.find(clase_id).diaHora
      )

      if clAlm.save
        redirect_to instructor_dianuevo_path(fecha: params[:fecha]), notice: 'Alumno agregado correctamente'
      else
        redirect_to instructor_dianuevo_path(fecha: params[:fecha]), alert: "Error: #{clAlm.errors.full_messages.join(', ')}"
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to instructor_dianuevo_path(fecha: params[:fecha]), alert: "Clase no encontrada"
    end
  end


# Añade estas acciones al final de tu AlumnosController

# POST /alumnos/:clase_id/alta_solicitud
def alta_solicitud
  unless AlumnosPolicy.new(current_usuario).puede_gestionar_clases?
    render file: "public/401.html", status: :unauthorized
    return
  end

  @clase = Clase.find(params[:clase_id])
  @solicitud = @clase.claseSolicitum.new(
    usuario_id: params[:usuario_id]
  )

  if @solicitud.save
    redirect_back fallback_location: root_path, notice: 'Solicitud añadida correctamente'
  else
    redirect_back fallback_location: root_path, 
                  alert: "Error al añadir solicitud: #{@solicitud.errors.full_messages.join(', ')}"
  end
end

# POST /alumnos/:clase_id/baja_solicitud/:id
def baja_solicitud
  @solicitud = ClaseSolicitum.find(params[:solicitud_id])
  fecha = params[:fecha] || Date.today.to_s

  if @solicitud.destroy
    redirect_to instructor_dianuevo_path(fecha: fecha), notice: 'Solicitud eliminada correctamente'
  else
    redirect_to instructor_dianuevo_path(fecha: fecha), alert: 'Error al eliminar la solicitud'
  end
rescue ActiveRecord::RecordNotFound
  redirect_to instructor_dianuevo_path(fecha: fecha), alert: 'Solicitud no encontrada'
end
# GET /alumnos/:clase_id/solicitudes
def solicitudes
  unless AlumnosPolicy.new(current_usuario).puede_gestionar_clases?
    render file: "public/401.html", status: :unauthorized
    return
  end

  @clase = Clase.includes(claseSolicitum: :usuario).find(params[:clase_id])
  render json: @clase.claseSolicitum.map { |s| 
    { id: s.id, usuario: s.usuario.nombre, usuario_id: s.usuario_id }
  }
end


def altaSolicitud
  begin
    @solicitud = ClaseSolicitum.new(
      clase_id: params[:clase_id],
      usuario_id: params[:usuario_id]
    )

    if @solicitud.save
      redirect_to instructor_dianuevo_path(fecha: params[:fecha]), notice: 'Solicitum agregado correctamente'
    else
      redirect_to instructor_dianuevo_path(fecha: params[:fecha]),
                  alert: "Error: #{@solicitud.errors.full_messages.join(', ')}"
    end
  rescue => e
    redirect_to instructor_dianuevo_path(fecha: params[:fecha]),
                alert: "Error al procesar la solicitud: #{e.message}"
  end
end

  private

  def clase_vacia
    redirect_to instructor_index_path(), alert: "Ese día no tienes clase"
  end
end

class InstructorController < ApplicationController
  def index
      @fechaHoy = Date.today
      @instructores = Instructor.all
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
                 @total = @total + 12
             elsif cl.claseAlumno.count < 9
                 @total = @total + 18
             else
                @total  = @total + 20
         end
       end
  end

  #Presenta las clases del día para el instructor que esté logueado.
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


  # Método POST
  # Recibe una id ClaseAlumno_id y lo borra
  def bajaPrueba
      Prueba.find(params[:prueba_id]).destroy
      redirect_to instructor_dia_url(params[:fecha])
  end

  # Método POST
  # Recibe un nombre, movil y id de la clase y cursa un alta
  def altaPrueba
      fecha = params[:fecha]

      Prueba.new(nombre: params[:nombre], movil: params[:movil], clase_id: params[:clase_id]).save
      redirect_to instructor_dia_url(params[:fecha])
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
      clAlmParam = params[:clase_alumno]

      fecha = params[:fecha]

      clAlm = ClaseAlumno.new
      clAlm.usuario_id = clAlmParam[:usuario_id]
      clAlm.clase_id = clAlmParam[:clase_id]
      clAlm.claseAlumnoEstado_id = clAlmParam[:claseAlumnoEstado_id]
      clAlm.diaHora = Clase.find(clAlmParam[:clase_id]).diaHora
      clAlm.instructor_id = Clase.find(clAlmParam[:clase_id]).instructor_id
      clAlm.save

      redirect_to instructor_dia_url(params[:fecha])
  end
  private

  def clase_vacia
    redirect_to instructor_index_path(), alert: "Ese día no tienes clase"
  end
end

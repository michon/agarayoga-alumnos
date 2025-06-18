class JulioController < ApplicationController
  layout 'julioLayout'
  skip_before_action :authenticate_usuario! # Esto salta la autenticación de Devise

  def index
      @q = Julio.ransack(params[:q])
      @q.sorts = 'nombre asc' if @q.sorts.empty?
      @alumnos = @q.result(distinct: true)
  end

  def asistencia
    @julio = Julio.find_by(usuario_id: params[:id])
    @usuario = @julio.usuario if @julio
  end

  def update
    @julio = Julio.find_by(usuario_id: params[:id])
    @usuario = @julio.usuario if @julio

    # Limpiar semanas si marcó "no viene"
    if params[:julio][:noviene] == '1'
      params[:julio][:sem1] = '0'
      params[:julio][:sem2] = '0'
      params[:julio][:sem3] = '0'
      params[:julio][:sem4] = '0'
      params[:julio][:sem5] = '0'
    end

    if @julio.update(julio_params)
      redirect_to asistencia_julio_path(@julio.usuario_id), notice: '¡Gracias por confirmar tu asistencia!'
    else
      render :asistencia
    end
  end

  def links
     @cl = ClaseAlumno.where(diaHora: '01-07-2024'.to_date.beginning_of_month.. '01-07-2024'.to_date.at_end_of_month).group(:usuario_id)
     @whatsapp_message = []
     Julio.all.each do |jl|
      url = asistencia_julio_url(jl.usuario_id)
      mensaje = <<~MSG
        Hola #{jl.usuario.alias} 👋

        Por favor, confirma tu asistencia para julio en el siguiente enlace:
        🔗 #{url}

        ¡Gracias por tu ayuda!
      MSG

      @whatsapp_message << [mensaje, jl.usuario]
    end
  end

  def facturar
     # generamos un array on las semanas del mes
     @semanal = ['01-07-2024..07-07-2024', '08-07-2024..14-07-2024','15-07-2024..21-07-2024', '22-07-2024..28-07-2024', '29-07-2024..31-07-2024']

     @clases = ClaseAlumno.where(diahora: '01-07-2024'.to_date.at_beginning_of_day..'31-07-2024'.to_date.at_end_of_day).joins(:usuario).order(:nombre)
     # Seleccionamos y recorremos todos los alumnos que vienen a clase en julio
    ClaseAlumno.where(diahora: '01-07-2024'.to_date.at_beginning_of_day..'07-07-2024'.to_date.at_end_of_day).group(:usuario_id).pluck(:usuario_id).each do | almId |
    end
    @claseAlumno = ClaseAlumno.all
  end


  private

  def julio_params
    params.require(:julio).permit(:sem1, :sem2, :sem3, :sem4, :sem5, :noviene)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:julio)
  end

end

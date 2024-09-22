class JulioController < ApplicationController

  def index
      @q = Julio.ransack(params[:q])
      @q.sorts = 'nombre asc' if @q.sorts.empty?
      @alumnos = @q.result(distinct: true)
  end


  def editar
    dd = Julio.find(params[:julio][:id])
    dd.sem1 = params[:julio][:sem1]
    dd.sem2 = params[:julio][:sem2]
    dd.sem3 = params[:julio][:sem3]
    dd.sem4 = params[:julio][:sem4]
    dd.sem5 = params[:julio][:sem5]
    dd.noviene = params[:julio][:noviene]
    dd.save

    redirect_to julio_index_path(anchor: "frm-#{params[:julio][:id]}")
  end
  

  def links
     @cl = ClaseAlumno.where(diaHora: '01-07-2024'.to_date.beginning_of_month.. '01-07-2024'.to_date.at_end_of_month).group(:usuario_id)
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

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:julio)
  end
end

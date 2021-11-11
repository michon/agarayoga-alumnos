class ClaseController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def semana()
      # horarioGeneral es un hash que tiene una entrada por cada hora (key) que
      # tenemos en el horario, cada una de estas entradas  contendrá otro hash
      # cuya clave será el día de la semana y el contenido un resitro de hoario.
      
      @fecha = params[:fecha].to_datetime

      @claseSemanal = Clase.select("*, date_format(diaHOra, '%H') as hora, date_format(diaHora, '%i') as minuto, date_format(diaHora, '%w') as dia").where(:diaHora => @fecha.beginning_of_week..@fecha.end_of_week).order(:hora, :minuto, :dia)

      @diasSemana = Clase.select("date_format(diaHora, '%w') as dia").where(:diaHora => @fecha.beginning_of_week..@fecha.end_of_week).order(:dia).distinct

      @horasDistintas = Clase.select("date_format(diaHora, '%H:%i') as hora").where(:diaHora => @fecha.beginning_of_week..@fecha.end_of_week).distinct

      
      @horarioGeneral = Hash.new

      @diasArray = Array.new
          Rails.logger.debug("Antes de nada -------- H O L A --------- ")

      @horasDistintas.each do |h|
          horaClase = h.hora
          @horarioGeneral.store(horaClase, Hash.new)
          for idx in @diasSemana.first.dia.to_i..@diasSemana.last.dia.to_i do 
              #montar un date time para esta @fecha y hora
              fechaCl  = @fecha.beginning_of_week.days_since(idx-1)
              fechaCl = fechaCl.change(hour: h.hora[0..1].to_i, min: h.hora[3..4].to_i)
              cl = Clase.where(diaHora: fechaCl).first
              @horarioGeneral[horaClase].store(fechaCl, cl)
          end
      end
  end

  def seleccion
      fecha = params[:fecha]
      redirect_to clase_semana_url(fecha)
  end

  def actual
      fecha = Date.today.to_datetime
      redirect_to clase_semana_url(fecha)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:fecha)
  end

end

class HorarioController < ApplicationController
    before_action :configure_permitted_parameters, if: :devise_controller?


    #nuevo horario para permitir mismo hora dos clases
  def nuevo
    
    if HorarioPolicy.new(current_usuario).verIndex?
      
        @horario = Horario.all
        @diasDistintos = Horario.select(:diaSemana).order(:diaSemana).distinct
        @horasDistintas = Horario.select(:hora, :minuto).order(:hora).distinct
        @horasDistintasInstructor = Horario.select(:instructor_id, :hora, :minuto).order(:hora, :minuto, :instructor_id).distinct
    else
      render :file => "public/401.html", :status => :unauthorized
    end
  end


  def index
      @instructores = Instructor.all

      # horarioGeneral es un hash que tiene una entrada por cada hora (key) que
      # tenemos en el horario, cada una de estas entradas  contendrá otro hash
      # cuya clave será el día de la semana y el contenido un resitro de hoario.

      if HorarioPolicy.new(current_usuario).verIndex?
        @horarioGeneral = Hash.new
        @horasDistintas = Horario.select(:hora, :minuto).order(:hora).distinct
        @horasDistintasInstructor = Horario.select(:instructor_id, :hora, :minuto).order(:instructor_id, :hora).distinct
        @alumnosPorInstructor = HorarioAlumno.all
        @alumnosInstrucorYClase = Horario.joins(:horarioAlumno).group(:instructor_id, :horario_id).select('horarios.*, count(horario_id) as cuenta').order(cuenta: :DESC)
        @diasDistintos = Horario.select(:diaSemana).order(:diaSemana).distinct
        @horario = Horario.all

        @diasArray = Array.new
        @horasDistintas.each do |h|
            horaClase = h.hora.to_s + ':' + "%02d" % h.minuto.to_s
            @horarioGeneral.store(horaClase, Hash.new)
            Horario.where(hora: h.hora, minuto: h.minuto).order(:hora).each do |d|
                @horarioGeneral[horaClase].store(d.diaSemana, d)
            end
        end
      else
        render :file => "public/401.html", :status => :unauthorized
      end
    end

  def libre
      # Es un array que contiene tantas posiciones como horas distintas hay de
      # clase. En cada una de estas posiciones se guardan tatos objetos Horario
      # como existan para esa hora.
      if HorarioPolicy.new(current_usuario).verLibres?
        @libres = Array.new(Horario.group(:hora).count.count)
        Horario.group(:hora).pluck(:hora).each_with_index do |hr,idx|
          @libres[idx] = Array.new(Horario.where(hora: hr))
        end
        @Clases = Horario.group(:hora,:minuto, :aula_id)
        @horario = Horario.all
      else
        render :file => "public/401.html", :status => :unauthorized
      end

  end



  def crearClases
      if HorarioPolicy.new(current_usuario).crearClases?
        require 'horario_clase.rb'
        objHorario = HorarioClase.new()

        fecha = params[:fecha].to_datetime

        objHorario.crearClases(fecha)
        redirect_to action: 'index'
      else
        render :file => "public/401.html", :status => :unauthorized
      end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:fecha)
  end
end

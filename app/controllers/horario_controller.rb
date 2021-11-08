class HorarioController < ApplicationController
    before_action :configure_permitted_parameters, if: :devise_controller?

  def index

      # horarioGeneral es un hash que tiene una entrada por cada hora (key) que
      # tenemos en el horario, cada una de estas entradas  contendrá otro hash
      # cuya clave será el día de la semana y el contenido un resitro de hoario.

      @horarioGeneral = Hash.new
      @horasDistintas = Horario.select(:hora, :minuto).order(:hora).distinct
      @diasDistintos = Horario.select(:diaSemana).order(:diaSemana).distinct

      @diasArray = Array.new
      @horasDistintas.each do |h|
          horaClase = h.hora.to_s + ':' + "%02d" % h.minuto.to_s
          @horarioGeneral.store(horaClase, Hash.new)
          Horario.where(hora: h.hora, minuto: h.minuto).order(:hora).each do |d|
              @horarioGeneral[horaClase].store(d.diaSemana, d)
          end
      end
      
  end

  def crearClases
      require 'horario_clase.rb'
      objHorario = HorarioClase.new()

      fecha = params[:fecha].to_datetime
      
      objHorario.crearClases(fecha)
      redirect_to action: 'index'
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:fecha)
  end
end

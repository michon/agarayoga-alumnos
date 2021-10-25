class HorarioController < ApplicationController
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
end

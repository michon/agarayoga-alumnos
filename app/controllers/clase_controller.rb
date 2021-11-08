class ClaseController < ApplicationController
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
          Rails.logger.debug("hora de clase #{horaClase}")
          Rails.logger.debug("Primer dia de la semana #{@diasSemana.first.dia.to_i}")
          Rails.logger.debug("último dia de la semana #{@diasSemana.last.dia.to_i}")
          @horarioGeneral.store(horaClase, Hash.new)
          for idx in @diasSemana.first.dia.to_i..@diasSemana.last.dia.to_i do 
              #montar un date time para esta @fecha y hora
              Rails.logger.debug "--------------------  Indice #{idx}"

              fechaCl  = @fecha.beginning_of_week.days_since(idx-1)
              fechaCl = fechaCl.change(hour: h.hora[0..1].to_i, min: h.hora[3..4].to_i)
              Rails.logger.debug "--------------------  @fecha de clase #{fechaCl.to_s}"
              cl = Clase.where(diaHora: fechaCl).first
              @horarioGeneral[horaClase].store(fechaCl, cl)
          end
      end
  end

  def actual
      fecha = Date.today.to_datetime
      redirect_to clase_semana_url(fecha)
  end
end

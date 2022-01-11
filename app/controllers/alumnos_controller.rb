class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'

  def index
      @alumnos = Usuario.where(debaja: [false,  nil]).all
  end

  def business
      @fecha = params[:fecha].to_datetime
      @fechaFin = DateTime.now
      @alumnos = Usuario.where(debaja: [false,  nil]).where(created_at: @fecha.beginning_of_month..@fechaFin.end_of_month).all
  end

  def show
      @id = params[:id]
      @almn = Usuario.find(params[:id])

      respond_to do |format|
          format.html

          format.pdf do
            ficha = FichaAlumno.new(@almn)
            ficNombre = "ficha_" + @almn.nombre.sub(" ", "-")
            send_data ficha.render, filename: ficNombre, type: 'application/pdf', diposition: 'inline'
          end
      end
  end

  def ficha
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def sepa
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def regalo
      usr= Usuario.find(params[:id])
      usr.regalo = (not usr.regalo)
      usr.save
      redirect_to alumnos_index_path
  end


  private

end

class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'

  def index
      @alumnos = Usuario.where(debaja: [false,  nil]).all
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


  private

end

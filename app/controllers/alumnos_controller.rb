class AlumnosController < ApplicationController
  def index
      @alumnos = Usuario.where(debaja: [false,  nil]).all
  end

  def show
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def ficha
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def sepa
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

end

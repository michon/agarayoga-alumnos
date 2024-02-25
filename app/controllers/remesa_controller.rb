class RemesaController < ApplicationController
  def index
    @rms = Remesa.all
  end

  def show
    @remesa = Remesa.find(params[:id])
    @rcbEstado = ReciboEstado.all
  end

  def new
  end

  def edit
  end
end

class HorarioController < ApplicationController
  def index
      @horario = Horario.all
  end
end

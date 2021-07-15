class ComunController < ApplicationController
    
    skip_before_action :authenticate_usuario!, :only => [:inicio]

  def indice
      CarteroMailer.bienvenido_email("hola").deliver!
  end

  def inicio
  end
end

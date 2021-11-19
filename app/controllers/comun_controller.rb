class ComunController < ApplicationController
    
    skip_before_action :authenticate_usuario!, :only => [:inicio]

  def indice
      if current_usuario && current_usuario.admin
          redirect_to michon_path
      elsif current_usuario
          redirect_to alumnos_path(current_usuario.id)
      else
        CarteroMailer.bienvenido_email("hola").deliver!
      end
  end

  def michon
      @fechaHoy = Date.today
  end


  def inicio
  end
end

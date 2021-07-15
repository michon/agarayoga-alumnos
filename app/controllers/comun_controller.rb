class ComunController < ApplicationController
    
  def indice
      CarteroMailer.bienvenido_email("hola").deliver!
  end
end

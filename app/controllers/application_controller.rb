class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_usuario!

    def after_sign_in_path_for(resource)
          #cambiar por la url del usuario en que acaba de realizar el acceso
         indice_path 
    end
end

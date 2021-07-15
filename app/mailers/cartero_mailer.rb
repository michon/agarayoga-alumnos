class CarteroMailer < ApplicationMailer

    default from: 'web@agarayoga.eu'

    def bienvenido_email(usuario)
        @usuario = "Miguel"
        @url = 'http://agarayoga.eu'
        mail(to: 'miguelrodriguez@softgalia.com', subject: 'probando ando', from: 'web@agarayoga.eu')
    end
        
end

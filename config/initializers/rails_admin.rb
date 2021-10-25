RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==

   config.authenticate_with do
     warden.authenticate! scope: :usuario
   end
   config.current_user_method(&:current_usuario)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'Instructor' do
    object_label_method do
        :custom_label_method
    end
  end

  config.model 'Usuario' do
    object_label_method do
        :usuario_label_method
    end
    list do
        scopes [:activo]
    end
  end

  config.model 'Horario' do 
      object_label_method do
          :horario_label_method
      end
      field :diaSemana, :enum do
        enum_method do
            :diasemana_enum
        end
      end
      field :hora
      field :minuto
      field :instructor
      field :usuario
  end

  config.model 'HorarioAlumno' do
      object_label_method do
          :horarioAlumno_label_method
      end
      field :instructor
      field :horario
  end

  config.model 'Clase' do 
      object_label_method do
          :clase_label_method
      end
      field :diaHora
      field :instructor
      field :usuario
  end



  def horarioAlumno_label_method
     self.usuario.nombre unless self.usuario.blank?
  end

  def usuario_label_method
     self.nombre
  end

  def horario_label_method
        semana = [['domingo','0'], ['lunes','1'], ['martes','2'], ['miércoles','3'], ['jueves','4'], ['viernes'],'5', ['sábado'],'6']
     semana[self.diaSemana][0].to_s + ' '  + self.hora.to_s + ':' + self.minuto.to_s
  end

  def clase_label_method
        self.diaHora
  end


  def custom_label_method
     self.nombre
  end

end

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

  config.model 'Aula' do
    object_label_method do
        :custom_label_method
    end
  end

  config.model 'Inscripcion' do
  end

  config.model 'Remesa' do
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
    field :nombre
    field :dni
    field :telefono
    field :movil
    field :direccion
    field :pais
    field :localidad
    field :provincia
    field :cp
    field :iban
    field :debaja
    field :codigofacturacion
    field :serie
    field :admin
    field :regalo
    field :grupoAlumno
    field :rol
    field :instructor
  end

  config.model 'Horario' do

      object_label_method do
          :horario_label_method
      end

      list do
        field :clase_humano
        field :instructor
        field :aula

        sort_by 'diaSemana, hora, minuto'
      end

      edit do 

        group :defalut do
          active false
          label  do 
            semana = ['domingo','lunes','martes','miércoles','jueves','viernes','sábado']
            h = bindings[:object]
            unless h.diaSemana.blank? then
            semana[h.diaSemana].to_s + ' '  + h.hora.to_s + ':' + h.minuto.to_s + ' - - - '  + h.instructor.nombre.to_s + ' (Aula ' + h.aula.nombre + ')'
            end
          end
          
          field :hora
          field :minuto
          field :diaSemana, :enum do
            enum_method do
              :diasemana_enum
            end
          end
          field :instructor
          field :aula
        end
        
        group :usuario do 
          label 'Alumnos' 
          field :usuario do
            label 'Alumnos'
          end
        end
        
      end
  end

  config.model 'HorarioAlumno' do
      object_label_method do
          :horarioAlumno_label_method
      end
      field :id
      field :horario
      field :usuario
  end

  config.model 'Clase' do
    list do
      sort_by :diaHora
    end
      object_label_method do
          :clase_label_method
      end
      field :diaHora
      field :instructor
      field :aula
  end

  config.model 'Prueba' do
      object_label_method do
          :prueba_label_method
      end
      field :clase
      field :nombre
  end

  config.model 'GrupoAlumno' do
      object_label_method do
          :grupoAlumno_label_method
      end
  end

  config.model 'ReciboEstado' do
      object_label_method do
        :reciboEstado_label_method
      end
  end

  config.model 'Recibo' do
      object_label_method do
        :recibo_label_method
      end
  end

  def recibo_label_method
      "(#{self.id.to_s}) #{self.nombre} (#{self.id.to_s})"
  end

  def reciboEstado_label_method
      self.nombre
  end

  def grupoAlumno_label_method
      self.nombre
  end

  def prueba_label_method
      self.nombre
  end

  def horarioAlumno_label_method
     self.usuario.nombre unless self.usuario.blank?
  end

  def usuario_label_method
     self.nombre
  end


  def clase_label_method
        self.diaHora.strftime('%a, %e %B %y a las %H:%M')
  end


  def custom_label_method
     self.nombre
  end

end

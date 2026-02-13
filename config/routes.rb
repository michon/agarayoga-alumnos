Rails.application.routes.draw do

  scope :wizard do
    resources :horario, only: [] do
      member do
        # Flujo principal del wizard
        get 'paso1_contexto', as: :paso1_contexto
        get 'paso2_seleccion', as: :paso2_seleccion
        get 'paso3_confirmacion', as: :paso3_confirmacion
        post 'ejecutar', as: :ejecutar

        # Ruta especial para invocación con contexto
        get 'iniciar/:alumno_id', to: 'wizard_horario#iniciar', as: :iniciar
      end
    end

    # También podemos tener rutas directas si prefieres
    get 'horario/alumno/:alumno_id/paso1', to: 'wizard_horario#paso1_contexto', as: :wizard_horario_paso1
    get 'horario/alumno/:alumno_id/paso2', to: 'wizard_horario#paso2_seleccion', as: :wizard_horario_paso2
    get 'horario/alumno/:alumno_id/paso3', to: 'wizard_horario#paso3_confirmacion', as: :wizard_horario_paso3
    post 'horario/alumno/:alumno_id/ejecutar', to: 'wizard_horario#ejecutar', as: :wizard_horario_ejecutar
    get 'wizard/horario/alumno/:alumno_id/paso4', to: 'wizard_horario#paso4_resultado', as: :wizard_horario_resultado
  end

  get  'julio/index'
  get  'julio/links'
  get  'julio/facturar'
  post 'julio/editar',                     to: 'julio#editar',       as: "julio/editar"
  get  'julio/generate_pdf',               to: 'julio#generate_pdf', as: 'julio_generate_pdf'
  post '/calcular_bic',                    to: 'alumnos#calcular_bic'

  resources :pruebas, only: [:new, :create]
  resources :solicitum, only: [:new, :create]


  resources :alumnos, except: [:index] do 
    member do
      post 'alta_clase'
      post 'baja_clase'
      post 'cambiar_estado'
      get 'clases_agendadas_pdf'

      get 'editar', to: 'alumnos#editar', as: 'editar'
      patch 'actualizar', to: 'alumnos#actualizar', as: 'actualizar'
      put 'actualizar', to: 'alumnos#actualizar'
      post 'sincronizar_facturacion', to: 'alumnos#sincronizar_facturacion', as: 'sincronizar_facturacion'
    end
    

    collection do
      get  'index'
      get  'clientes'
      get  'enhorario'
      get  'clasesJulioURL'
      
      get 'alta', to: 'alumnos#nueva_alta', as: 'nueva_alta'
      post 'alta', to: 'alumnos#crear_alta', as: 'crear_alta'

      post ':clase_id/alta_prueba', to: 'alumnos#alta_prueba', as: 'alta_prueba'
      post ':clase_id/baja_prueba/:id', to: 'alumnos#baja_prueba', as: 'baja_prueba'
      post ':clase_id/alta_solicitud', to: 'alumnos#alta_solicitud', as: 'alta_solicitud'
      post ':clase_id/baja_solicitud/:id', to: 'alumnos#baja_solicitud', as: 'baja_solicitud'
    end
  end

      get  'alumnos/ficha/:id',              to: 'alumnos#ficha',           as: 'alumnos_ficha'
      get  'alumnos/pdfAlumnos',             to: 'alumnos#pdfAlumnos',      as: "alumnos/pdfAlumnos"

      get  'alumnos/actualizar/:id',         to: 'alumnos#actualizar',      as: 'alumnos/actualizar'
      get  'alumnos/clases_julio/:id',       to: 'alumnos#clasesJulio',     as: 'alumnos/clases_julio'
      get  'alumnos/clases_agendadas/:id',   to: 'alumnos#clasesJulio',     as: 'alumnos/clases_agendadas'
      get  'alumnos/regalo/:id',             to: 'alumnos#regalo',          as: 'alumnos_regalo'
      get  'alumnos/navidad/:id',            to: 'alumnos#navidad',         as: 'alumnos_navidad'
      get  'alumnos/sepa/:id',               to: 'alumnos#sepa',            as: 'alumnos_sepa'
      get  'alumnos/business/:fecha',        to: 'alumnos#business',        as: 'alumnos/business_get'
      post 'alumnos/business/',              to: 'alumnos#business',        as: 'alumnos/business'
      post 'alumnos/procesos/',              to: 'alumnos#procesos',        as: 'alumnos/procesos'
      get  'alumnos/procesos/:proceso',      to: 'alumnos#procesos',        as: 'alumnos/procesos_get'
      post 'alumnos/procesosAlta/',          to: 'alumnos#procesosAlta' ,   as: 'alumnos/procesos_alta'

      post 'alumnos/:id/clasesAgendadas', to: 'alumnos#clasesAgendadas', as: 'alumno_clasesAgendadas'
      get 'alumnos/:id/clases_agendadas', to: 'alumnos#clasesAgendadas', as: 'alumno_clases_agendadas'

      get  'alumnos/procesosAlta/:proceso',  to: 'alumnos#procesosAlta',    as: 'alumnos/procesos_alta_get'
      post 'alumnos/:id/generar_clave', to: 'alumnos#generar_clave', as: 'generar_clave_alumno'


      resources :julio, only: [:show, :update] do
        get 'asistencia', on: :member, as: 'asistencia'
      end

    get 'stats/dashboard', to: 'stats#dashboard'
    get 'stats/monthly_comparison', to: 'stats#monthly_comparison'
    get 'stats/evolucion_ingresos', to: 'stats#evolucion_ingresos'
    get 'stats/asistencia_mensual', to: 'stats#asistencia_mensual'
    get 'stats/asistencia_instructor', to: 'stats#asistencia_instructor'

  get 'remesa/index'
  get 'remesa/show/:id',                           to: 'remesa#show',                as: 'remesa/show'
  get 'remesa/new'
  get 'remesa/quitarRecibo/:rcb_id,:rms_id',       to: 'remesa#quitarRecibo',        as: 'remesa/quitarRecibo'
  get 'remesa/edit'
  get 'remesa/emitir/:id',                         to: 'remesa#emitir',              as: 'remesa/emitir'
  post 'remesa/anhadirRcbARemesa',                 to: 'remesa#anhadirRcbARemesa',   as: "remesa/anhadirRcbARemesa"

  get  'caja/listado'
  get  'caja/modificar'
  get  'caja/ver'
  post 'cajas/nuevo',                              to: 'caja#nuevo',          as: 'caja/nuevo'

  get    'recibo/pagos/',                          to: 'recibo#pagos',                           as: 'recibo/pagos'
  get    'recibo/facturar',                        to: 'recibo#facturar',                        as: 'recibo/facturar'
  get    'recibo/facturacion',                     to: 'recibo#facturacion',                     as: 'recibo/facturacion'
  get    'recibo/pagar/:id',                       to: 'recibo#pagar',                           as: 'recibo/pagar'
  get    'recibo/facturaPdf/:id',                  to: 'recibo#facturaPdf',                      as: 'recibo/facturaPdf'
  get    'recibo/generar/:fecha',                  to: 'recibo#generar',                         as: 'recibo/generar'
  get    'recibo/remesar_seleccionar/',            to: 'recibo#remesarSeleccionar',              as: 'recibo/remesarSeleccionar'
  get    'recibo/remesar_seleccionar_todos/',      to: 'recibo#remesar_seleccionar_todos',       as: 'recibo/remesar_seleccionar_todos'
  get    'recibo/remesar_seleccionar_actual/',     to: 'recibo#remesar_seleccionar_actual',      as: 'recibo/remesar_seleccionar_actual'
  get    'recibo/remesar_seleccionar_anterior/',   to: 'recibo#remesar_seleccionar_anterior',    as: 'recibo/remesar_seleccionar_anterior'
  post   'recibo/exportar_facturadirecta',         to: 'recibo#exportar_facturadirecta'
  post   'recibo/remesar_seleccionar_post',        to: 'recibo#remesarSeleccionarPost',          as: "recibo/remesarSeleccionarPost"
  get    'recibo/estado/:id/:estado' ,             to: 'recibo#estado',                          as: 'recibo/estado'
  get    'recibo/numerar',                         to: 'recibo#numerar',                         as: 'recibo/numerar'
  post   'recibo/yacob',                           to: 'recibo#yacob',                           as: 'recibo/yacob'
  post   'recibo/generarPost',                     to: 'recibo#generarPost',                     as: 'recibo/generarPost'
  post   'recibo/busqueda',                        to: 'recibo#busqueda',                        as: "recibo/busqueda"
  post   'recibo/remesar',                         to: 'recibo#remesar',                         as: "recibo/remesar"
  post   'recibo/modificar',                       to: 'recibo#modificar',                       as: "recibo/modificar"
  post   'recibo/descargarFacturacion',            to: 'recibo#descargarFacturacion',            as: "recibo/descargarFacturacion"
  post   'recibo/numerarPost',                     to: 'recibo#numerarPost',                     as: 'recibo/numerarPost'
  post   'cambiar_estado',                         to: 'recibo#cambiar_estado',                  as: 'cambiar_estado'
  resources :recibo, only: [:destroy]

# REEMPLAZA el namespace por estas rutas personalizadas:
get     'gestion/recibos',          to: 'recibo#index',     as: 'gestion_recibos'
get     'gestion/recibos/new',      to: 'recibo#new',       as: 'new_gestion_recibo'
post    'gestion/recibos',          to: 'recibo#create',    as: 'create_gestion_recibo'
get     'gestion/recibos/:id',      to: 'recibo#show',      as: 'gestion_recibo'
get     'gestion/recibos/:id/edit', to: 'recibo#edit',      as: 'edit_gestion_recibo'
patch   'gestion/recibos/:id',      to: 'recibo#update',    as: 'update_gestion_recibo'
put     'gestion/recibos/:id',      to: 'recibo#update'
delete  'gestion/recibos/:id',      to: 'recibo#destroy',   as: 'destroy_gestion_recibo'


resources :clase_alumno, only: [:destroy]


  get    'clase/semana/:fecha',                    to: "clase#semana",                          as: "clase/semana"
  get    'clase/dia/:fecha',                       to: 'clase#dia',                             as: "clase/dia"
  get    'clase/actual'
  get    'clase/clasesDesde',                      to: 'clase#clasesDesde',                     as: "clase/clasesDesde"
  get    'clase/calendario',                       to: 'clase#calendario',                      as: "clase/calendario"
  get    'clase/libre',                            to: 'clase#libre',                           as: "clase/libre"

  post   'clase/semana',                           to: 'clase#seleccion',                       as: "clase/seleccion"
  post   'clase/dia',                              to: 'clase#seleccionDia',                    as: "clase/seleccion_dia"
  post   'clase/altaAlumno',                       to: 'clase#altaAlumno',                      as: "clase/alta_alumno"
  post   'clase/bajaAlumnos',                      to: 'clase#bajaAlumnos',                     as: "clase/baja_alumnos"
  post   'clase/anularClase',                      to: 'clase#anularClase',                     as: "clase/anular_clase"
  post   'clase/altaPrueba',                       to: 'clase#altaPrueba',                      as: "clase/alta_prueba"
  post   'clase/bajaPrueba',                       to: 'clase#bajaPrueba',                      as: "clase/baja_prueba"
  post   'clase/estado',                           to: 'clase#estado',                          as: "clase/estado"
  post   'clase/altaSolicita',                     to: 'clase#altaSolicita',                    as: "clase/alta_solicita"
  post   'clase/bajaSolicita',                     to: 'clase#bajaSolicita',                    as: "clase/baja_solicita"
  resources :clase, only: [:destroy]



  get    'horario/index'
  get    'horario/libre'
  get    'horario/nuevo'
  get    'horario/crear'
  get    'horario/delete/:id',            to: 'horario#delete',                as: 'horario/delete'
  post   'horario/crear_horario_semanal', to: 'horario#crearClases'
  post   'horario/crear_horario_julio',   to: 'horario#crearJulio'

  resources :horario_alumnos, only: [:destroy], controller: 'horario_alumno', path: 'horario_alumno'



  get    'instructor/index'
  get    'instructor/agenda'
  get    'instructor/show/:id/:fecha',to: 'instructor#show', as: 'instructor'
  get    'instructor/dia/:fecha',     to: 'instructor#dia',  as: "instructor/dia"
  get    'instructor/dianuevo/:fecha',     to: 'instructor#dianuevo',  as: "instructor/dianuevo"
  post   'instructor/dia',            to: 'instructor#seleccionDia', as: "instructor/seleccion_dia"
  post   'instructor/altaAlumno',     to: 'instructor#altaAlumno',   as: "instructor/alta_alumno"
  post   'instructor/bajaAlumnos',    to: 'instructor#bajaAlumnos',  as: "instructor/baja_alumnos"
  post   'instructor/altaPrueba',     to: 'instructor#altaPrueba',   as: "instructor/alta_prueba"
  post   'instructor/bajaPrueba',     to: 'instructor#bajaPrueba',   as: "instructor/baja_prueba"
  post 'instructor/baja_solicitud/:solicitud_id', to: 'instructor#baja_solicitud', as: 'instructor_baja_solicitud'
  post 'update_estado_alumno', to: 'instructor#update_estado_alumno'
  post 'instructor/altaSolicitud', to: 'instructor#altaSolicitud', as: :instructor_alta_solicitud
  patch 'instructor/update_estado_alumno', to: 'instructor#update_estado_alumno'

  get 'indice',       to: 'comun#indice'
  get 'inicio',       to: 'comun#inicio'
  get 'michon',       to: 'comun#michon'
  get 'facturacion',  to: 'comun#facturacion'


  # solo michon accede al entorno de administración
  authenticate :usuario, lambda { |u| u.rol == "michon" } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :usuario


  root to: 'comun#indice'
end

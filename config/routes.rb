Rails.application.routes.draw do
  get    'clase/semana/:fecha', to: "clase#semana",       as: "clase/semana"
  get    'clase/dia/:fecha',    to: 'clase#dia',          as: "clase/dia"
  get    'clase/actual'
  post   'clase/semana',        to: 'clase#seleccion',    as: "clase/seleccion"
  post   'clase/dia',           to: 'clase#seleccionDia', as: "clase/seleccion_dia"
  post   'clase/altaAlumno',    to: 'clase#altaAlumno',   as: "clase/alta_alumno"
  post   'clase/bajaAlumnos',   to: 'clase#bajaAlumnos',  as: "clase/baja_alumnos"
  post   'clase/altaPrueba',    to: 'clase#altaPrueba',   as: "clase/alta_prueba"

  post   'clase/estado',        to: 'clase#estado',       as: "clase/estado"


  get 'horario/index'
  post 'horario/crear_horario_semanal', to: 'horario#crearClases'

  get 'instructor/index'
  get 'instructor/show'

  get 'alumnos/index'
  get 'alumnos/show/:id', to: 'alumnos#show', as: 'alumnos'
  get 'alumnos/ficha/:id', to: 'alumnos#ficha', as: 'alumnos_ficha'
  get 'alumnos/sepa/:id', to: 'alumnos#sepa', as: 'alumnos_sepa'
  
  get 'indice', to: 'comun#indice'
  get 'inicio', to: 'comun#inicio'
  get 'michon',  to: 'comun#michon'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :usuario


  root to: 'comun#inicio'
end

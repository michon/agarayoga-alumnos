Rails.application.routes.draw do
  get 'clase/semana/:fecha', to: "clase#semana", as: "clase/semana"
  get 'clase/actual'
  get 'horario/index'
  post 'horario/crear_horario_semanal', to: 'horario#crearClases'
  get 'instructor/index'
  get 'instructor/show'
  get 'alumnos/index'
  get 'alumnos/show/:id', to: 'alumnos#show', as: 'alumnos'
  get 'alumnos/ficha/:id', to: 'alumnos#ficha', as: 'alumnos_ficha'
  get 'alumnos/sepa/:id', to: 'alumnos#sepa', as: 'alumnos_sepa'
  

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :usuario

  get 'indice', to: 'comun#indice'
  get 'inicio', to: 'comun#inicio'

  root to: 'comun#inicio'
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :usuario

  get 'indice', to: 'comun#indice'
  get 'inicio', to: 'comun#inicio'

  root to: 'comun#inicio'
end

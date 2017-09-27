Rails.application.routes.draw do
  root to: 'students#index'
  get 'healthcheck', to: 'healthchecks#index'
  resources :students
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

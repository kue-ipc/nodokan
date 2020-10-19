Rails.application.routes.draw do
  resources :networks
  resources :confirmations
  root to: 'pages#top'
  get 'about', to: 'pages#about'

  resources :nodes do
    member do
      get 'copy'
    end
  end
  resources :operating_systems, only: [:index]

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

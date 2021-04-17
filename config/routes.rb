Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'pages#top'
  get 'about', to: 'pages#about'

  resources :nodes do
    member do
      get 'copy'
    end
    resource :confirmation, only: [:create, :update]
  end

  resources :networks

  resources :places, only: [:index, :edit, :update]
  resources :hardwares, only: [:index, :edit, :update]
  resources :operating_systems, only: [:index]
  resources :security_softwares, only: [:index]

  resources :users, only: [:index, :show, :create, :update] do
    collection do
      put 'sync'
    end
    # resources :networks, only: [:create, :destroy], controller: 'user_networks'

    member do
      post 'networks', to: 'users#create_network', as: 'networks'
      delete 'networks/:network_id', to: 'users#delete_network', as: 'network'
    end
  end

  resource :user, only: [:show]

  devise_for :users, path: 'auth'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end

Rails.application.routes.draw do
  root to: 'pages#top'
  get 'about', to: 'pages#about'

  resources :nodes do
    member do
      get 'copy'
    end
  end

  resources :networks

  resources :confirmations

  resources :places, only: [:index, :edit, :update]
  resources :hardwares, only: [:index, :edit, :update]
  resources :operating_systems, only: [:index]

  resources :users, only: [:index, :show, :create, :update] do
    collection do
      put 'sync'
    end
  end
  resource :user, only: [:show]

  resources :network_users, only: [:show, :create, :update, :destroy]

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end

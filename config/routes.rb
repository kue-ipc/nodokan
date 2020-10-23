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

  resources :places, only: [:index, :edit, :update] do
    member do
      patch 'merge'
    end
  end

  resources :operating_systems, only: [:index]

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end

Rails.application.routes.draw do
  get 'hardwares/index'
  get 'hardwares/edit'
  get 'hardwares/update'
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

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end

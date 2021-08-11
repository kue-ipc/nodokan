Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'pages#top'
  get 'about', to: 'pages#about'

  resources :nodes do
    member do
      get 'copy'
      post 'transfer'
    end
    resource :confirmation, only: [:create, :update]
    resource :specific_node_application, only: [:new, :create]
  end

  resources :networks

  defaults format: :json do
    resources :places, only: [:index, :show, :create, :update, :destroy]
    resources :hardwares, only: [:index, :show, :create, :update, :destroy]
    resources :operating_systems, only: [:index, :show, :create, :update, :destroy]
    resources :security_softwares, only: [:index, :show, :create, :update, :destroy]
  end

  namespace 'manage' do
    get 'places'
    get 'hardwares'
    get 'operating_systems'
    get 'security_softwares'
    end

  resources :users, only: [:index, :show, :update] do
    collection do
      put 'sync'
    end
    # resources :networks, only: [:create, :destroy], controller: 'user_networks'

    resources :use_networks, only: [:create, :update, :destroy]
    # member do
    #   post 'networks', to: 'users#create_network', as: 'networks'
    #   delete 'networks/:network_id', to: 'users#delete_network', as: 'network'
    # end
  end

  resource :user, only: [:show]

  devise_for :users, path: 'auth'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: '/delayed_job'
  end
end

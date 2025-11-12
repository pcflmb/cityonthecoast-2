Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Admin namespace
  namespace :admin do
    resources :events do
      member do
        get :versions
        post :revert
      end
    end

    root 'events#index'
  end

  # Public API
  namespace :api do
    resources :events, only: [:index, :show]
  end

  # Public site
  resources :registrations, only: [:new, :create]
  resources :events, only: [:index, :show]
  get "holiday" => 'events#index'
  get "holidays" => 'events#index'
  root 'events#index'
end

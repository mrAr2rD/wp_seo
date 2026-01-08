Rails.application.routes.draw do
  # Mount Rswag only in development/test environments
  if defined?(Rswag)
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Devise routes for authentication
      devise_for :users, path: "users", controllers: {
        sessions: "api/v1/users/sessions",
        registrations: "api/v1/users/registrations"
      }

      # Projects routes
      resources :projects do
        member do
          post :validate_wordpress
        end
        resources :articles, only: [:index, :create]
      end

      # Articles routes
      resources :articles, only: [:show, :update, :destroy] do
        member do
          post :publish
        end
      end

      # Subscriptions routes
      resources :subscriptions, only: [:index, :create, :update, :destroy] do
        collection do
          post :webhook
        end
      end

      # Plans routes
      resources :plans, only: [:index, :show]

      # Current user route
      get "current_user", to: "users#show"
    end
  end

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [:index, :show, :update]
    resources :subscriptions, only: [:index, :show]
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end

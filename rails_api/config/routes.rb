Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      resources :users do
        resources :participations, only: :index
      end
      resources :participations
      resources :activities, only: [:index, :show] do
        resources :participations, only: :index
        resources :users, only: :index
      end
      resources :trips do
        member do
          get :summary
          put :mark_deleted
        end
        resources :users, only: :index
        resources :destinations do
          resources :places
        end
        resources :activities do
          put :mark_deleted, on: :member
          resources :participations, only: :index
        end
        resources :expenses
      end
    end
  end
  match "*path", to: "application#not_found", via: :all
  root "application#not_found"
end

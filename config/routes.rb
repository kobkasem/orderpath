Rails.application.routes.draw do
  # Root healthcheck endpoint
  root to: 'api/v1/monitoring#status'
  
  namespace :api do
    namespace :v1 do
      # Customer API endpoints
      resources :orders, only: [:create, :show, :index] do
        member do
          post :reprocess
          post :reprint
        end
      end
      
      # Printer management
      resources :printers, only: [:index, :create, :update, :destroy, :show]
      
      # Inventory management
      resources :skus, only: [:index, :show, :create, :update] do
        resources :inventory_locations, only: [:index]
      end
      
      # Picking management
      resources :picking_slips, only: [:index, :show, :create] do
        member do
          post :reprint
        end
      end
      
      # Monitoring and management
      get 'monitoring/status', to: 'monitoring#status'
      get 'monitoring/errors', to: 'monitoring#errors'
      post 'monitoring/retry_failed', to: 'monitoring#retry_failed'
    end
  end
end



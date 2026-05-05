Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Root path - redirects based on role
  root 'root#index'

  # Questions and Answers
  resources :questions, only: [:show] do
    resources :answers, only: [:create, :index]
  end

  get 'invite/:token', to: 'invite_tokens#join', as: :join_invite

  # Validation
  post 'validate-answer', to: 'validation#validate_answer'

  # Admin namespace
  namespace :admin, path: 'admin' do
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    get 'form-template', to: 'forms#template', as: :form_template
    post 'validate-question', to: 'forms#validate_question'

    resources :companies, only: [] do
      resources :invite_tokens, only: [:index, :create, :destroy] do
        member do
          patch :deactivate
        end
      end

      resources :company_members, only: [:index, :update, :destroy]
    end

    resources :questions do
      resources :choices, only: [:create, :update, :destroy]
      get 'statistics', to: 'statistics#show', as: :statistics
      resources :answers, only: [] do
        resources :admin_replies, only: [:index, :create, :destroy]
      end
      member do
        get 'export/pdf', to: 'exports#pdf', as: :export_pdf
        get 'export/csv', to: 'exports#csv', as: :export_csv
      end
    end

    resources :recurring_schedules, only: [:index, :create, :update, :destroy] do
      member do
        patch :pause
        patch :resume
      end
    end
  end

  # Member namespace
  namespace :member, path: 'member' do
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    resources :questions, only: [:index, :show]
    resources :answers, only: [:index]
  end

  # Health check and PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

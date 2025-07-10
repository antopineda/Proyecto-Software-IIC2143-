Rails.application.routes.draw do
  get 'submissions/create'

  # Devise routes modifications
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # Rutas de cursos, reviews, lessons, quizzes y questions (anidadas al curso)
  resources :courses do
    member do
      delete 'unsubscribe', to: 'courses#unsubscribe'
    end
    resources :reviews
    resources :enrollment_requests, only: [:create, :destroy, :show, :update] do
      delete 'cancel', on: :member, to: 'enrollment_requests#cancel', as: :cancel
      collection do
        get 'pending', to: 'enrollment_requests#pending_for_course', as: :pending_for_course
        patch 'update', to: 'enrollment_requests#update_request', as: :update_request
      end
    end
    resources :lessons do
      resources :quizzes do
        resources :questions
        resources :submissions, only: [:show, :create]

      end
    end
    
    resources :rooms do
      resources :messages
    end
  end

  resources :enrollment_requests, only: [:create, :update] do
    collection do
      get 'pending_requests', to: 'enrollment_requests#pending_requests'
    end
  end 

  resources :enrollment_requests, only: [:index]
  resources :courses, only: [:index]

  # Rutas de reviews
  get 'reviews/index'
  get 'reviews/create'
  get 'reviews/new'
  get 'reviews/edit'
  get 'reviews/show'
  get 'reviews/update'
  get 'reviews/destroy'
  
  # Manual routes

    # Render controller
  get 'render/index'

    # User controller (creador por nosotros, no el default)
  get 'user/myprofile'
  get 'user/show/:id', to: 'user#show', as: 'user'

    # Ruta para manejo de error cuando cerramos sesión de cuenta (video 13 JEAN PHILIPE min 18:40)
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
  end

    # About ClassMate page
  get 'render/about'
  
    # Root route
  root "render#index"
end

Music::Application.routes.draw do
  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"
  get "signup", to: "users#new", as: "signup"

  resources :users, except: [:new] do
    collection do
      get 'activate'
    end
  end

  resources :bands do
    resources :albums, only: [:index, :new, :create]
  end

  resources :albums, except: [:index, :new, :create] do
    resources :tracks, only: [:index, :new, :create]
  end

  resources :tracks, except: [:index, :new, :create] do
    resources :notes, only: [:new]
  end

  resources :notes, only: [:create, :destroy, :edit, :update]
end
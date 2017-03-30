GoalApp::Application.routes.draw do
  root :to => 'goals#index'

  resources :users, :only => [:new, :create, :show]
  resource :session, :only => [:new, :create, :destroy]
  resources :goals do
    member do
      get 'mark/unfinished', to: 'goals#change_finished_state'
      get 'mark/finished', to: 'goals#change_finished_state'
    end
  end
end

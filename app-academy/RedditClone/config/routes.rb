RedditClone::Application.routes.draw do
  resources :users, :except => [:index]
  resources :subs
  resources :links do
    resources :comments, :only => [:new]
  end

  resources :comments, :except => [:new] do
    member do
      post 'vote'
    end
  end

  resource :session, :only => [:new, :create, :destroy]
end

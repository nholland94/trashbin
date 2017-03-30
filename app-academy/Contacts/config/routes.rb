Contacts::Application.routes.draw do
  resources :users do
    resources :contacts, only: [:index, :create]
  end

  resources :contacts, only: [:show, :update, :destroy]
  get '/contacts' => 'contacts#index_all'

  resources :contact_shares, :except => [:new, :edit]
end

Rails.application.routes.draw do
  resources :call_lists do
    collection { post :import }
  end
  devise_for :users, controllers: { registrations: "users/registrations" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#show'
end

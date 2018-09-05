Rails.application.routes.draw do
  resources :author_lists
  resources :on_specials
  resources :dont_sells
  get 'call_lists/multi'
  get 'call_lists/list'
  get 'call_lists/selected'
  get 'call_lists/not_called'
  get 'call_lists/not_ordered'
  get 'call_lists/not_on_list'
  get 'call_lists/no_customer'
  get 'call_lists/all_customer'
  resources :call_lists do
    collection { post :import }
  end
  devise_for :users, controllers: { registrations: "users/registrations" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#show'
end

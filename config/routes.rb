Rails.application.routes.draw do
root 'users#home'

  resources :musicians  , only: [:index]
  get 'users/updatepassword', :to => 'users#updatepassword'
  resources :users do
    resources :bookings, only: [:new, :create, :update, :destroy] do
      resources :reviews, only:[:new, :create, :index]
    end
  end

  resources :sessions, only: [:new, :create]
  delete 'logout' => 'sessions#destroy'

#  get 'update' => 'user_controller#update'
# end

end

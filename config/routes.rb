
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }

  resources :movies, only: [:index, :show, :create, :update, :destroy, :new, :edit] do
    collection do
      get 'search', defaults: { format: :json }
    end
  end

  get '/:movie_id/casts/:cast_id', to: 'movies#movie_cast', as: 'movie_cast'
  get 'movies_by_genre/:id', to: 'movies#movies_by_genre', as: 'movies_by_genre'

  get 'movies/check_movie_details/:tmdb_id', to: 'movies#check_movie_details', as: 'check_movie_details'
  post 'movies/save_movie_details/:tmdb_id', to: 'movies#save_movie_details', as: 'save_movie_details'

  scope 'users' do
    get 'phone_number_form', to: 'users#phone_number_form', as: 'phone_number_form'
    post 'verify_phone_number', to: 'users#verify_phone_number', as: 'verify_phone_number'
    get 'otp_verification_form', to: 'users#otp_verification_form', as: 'otp_verification_form'
    post 'verify_otp', to: 'users#verify_otp', as: 'verify_otp'
  end


  root 'movies#index'
end

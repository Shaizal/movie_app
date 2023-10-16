Rails.application.routes.draw do
  resources :movies, only: [:index, :show, :create, :update, :destroy, :new, :edit] do
    collection do
      get 'search', defaults: { format: :json }
    end
  end

  get '/:movie_id/casts/:cast_id', to: 'movies#movie_cast', as: 'movie_cast'
  get 'movies_by_genre/:id', to: 'movies#movies_by_genre', as: 'movies_by_genre'

  get 'movies/check_movie_details/:tmdb_id', to: 'movies#check_movie_details', as: 'check_movie_details'
  post 'movies/save_movie_details/:tmdb_id', to: 'movies#save_movie_details', as: 'save_movie_details'

  root 'movies#index'
end

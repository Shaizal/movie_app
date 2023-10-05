Rails.application.routes.draw do
  get '/:movie_id/casts/:cast_id', to: 'movies#movie_cast', as: 'movie_cast'
  get 'movies_by_genre/:id', to: 'movies#movies_by_genre', as: 'movies_by_genre'

  resources :movies do
    collection do
      get 'search', defaults: { format: :json }
    end
  end

  root 'movies#index'
end

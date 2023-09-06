Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :movies
  get '/:movie_id/casts/:cast_id', to: 'movies#movie_cast', as: 'movie_cast'
  get 'movies_by_genre/:id', to: 'movies#movies_by_genre', as: 'movies_by_genre'
  root 'movies#index'
  # Defines the root path route ("/")
  # root "articles#index"
end

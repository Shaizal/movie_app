require 'faraday'


class TmdbApi
  API_KEY = '2717f4879f2c391fd2d68b9f9955b558'

  def initialize
    @connection = Faraday.new(url: 'https://api.themoviedb.org/3/')
  end

  def fetch_movie(movie_title)
    response = @connection.get("search/movie?api_key=#{API_KEY}&query=#{movie_title}")
    JSON.parse(response.body)['results'].first
  end

  def fetch_genre_mapping
    response = @connection.get("genre/movie/list?api_key=#{API_KEY}")
    genre_list = JSON.parse(response.body)['genres']

    genre_mapping = {}
    genre_list.each do |genre|
      genre_mapping[genre['id']] = genre['name']
    end

    genre_mapping
  end

  def fetch_cast(movie_id)
    response = @connection.get("movie/#{movie_id}/credits?api_key=#{API_KEY}")
    JSON.parse(response.body)['cast']
  end

  
end

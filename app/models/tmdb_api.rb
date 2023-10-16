require 'faraday'

class TmdbApi
  API_KEY = '2717f4879f2c391fd2d68b9f9955b558'

  def initialize
    @connection = Faraday.new(url: 'https://api.themoviedb.org/3/')
    @genre_mapping = nil
  end

  def fetch_movie_by_id(tmdb_id)
    response = @connection.get("movie/#{tmdb_id}?api_key=#{API_KEY}")
    JSON.parse(response.body)
  rescue JSON::ParserError
    return nil
  end

  def fetch_genre_mapping
    @genre_mapping ||= begin
      response = @connection.get("genre/movie/list?api_key=#{API_KEY}")
      genre_list = JSON.parse(response.body)['genres']

      genre_mapping = {}
      genre_list.each do |genre|
        genre_mapping[genre['id']] = genre['name']
      end

      genre_mapping
    end
  rescue JSON::ParserError
    return {}
  end

  def fetch_cast(movie_id)
    response = @connection.get("movie/#{movie_id}/credits?api_key=#{API_KEY}")
    JSON.parse(response.body)['cast']
  rescue JSON::ParserError
    return []
  end

  def search_movies(query)
    response = @connection.get("search/movie?api_key=#{API_KEY}&query=#{query}")
    results = JSON.parse(response.body)['results']

    return results unless results.empty?
  rescue JSON::ParserError
    return []
  end
end

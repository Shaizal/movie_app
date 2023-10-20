require 'concurrent'

class MoviesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def show
    @movie = Movie.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @movie }
    end
  end



  def index
    if params[:search].present?
      db_results = Movie.where("title LIKE ?", "%#{params[:search]}%")

      tmdb_api = TmdbApi.new
      api_movies = tmdb_api.search_movies(params[:search])

      if api_movies.present?
        @movies = []

        thread_pool = Concurrent::FixedThreadPool.new(5)

        api_movies.each do |api_movie|
          tmdb_id = api_movie['id']
          saved_movie = Movie.find_by(tmdb_id: tmdb_id)

          if saved_movie
            @movies << saved_movie
          else
            thread_pool.post do
              save_movie_details(tmdb_id)
            end

            @movies << Movie.new(
              title: api_movie['title'],
              tmdb_id: tmdb_id,
              year: api_movie['release_date'].split('-').first
            )
          end
        end

        @movies += db_results

        @movies.uniq!
      else
        @movies = db_results
      end
    else
      @movies = Movie.all.order(title: :asc)
    end

    respond_to do |format|
      format.html
      format.json { render json: @movies }
    end
  end


  def check_movie_details
    tmdb_id = params[:tmdb_id]
    saved_movie = Movie.find_by(tmdb_id: tmdb_id)

    if saved_movie
      Rails.logger.info("Movie details found - ID: #{saved_movie.id}")
      ActiveRecord::Base.connection_pool.release_connection
      redirect_to movie_path(saved_movie.id)
    else
      movie_id = save_movie_details(tmdb_id)
      if movie_id
        Rails.logger.info("Movie details saved - ID: #{movie_id}")
        ActiveRecord::Base.connection_pool.release_connection
        redirect_to movie_path(movie_id)
      else
        Rails.logger.info("Movie details not found or saved.")
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end



  def save_movie_details(tmdb_id)
    tmdb_api = TmdbApi.new
    movie_details = tmdb_api.fetch_movie_by_id(tmdb_id)

    puts "tmdb_id: #{tmdb_id}"
    puts "movie_details: #{movie_details.inspect}"

    if movie_details && movie_details['title']
      genre_mapping = tmdb_api.fetch_genre_mapping

      if movie_details['genres'].present? && movie_details['genres'][0].present? && movie_details['genres'][0]['id'].present?
        genre_id = movie_details['genres'][0]['id']
        genre_name = genre_mapping[genre_id] || 'Unknown'
      else
        genre_name = 'Unknown'
      end

      genre = Genre.find_or_create_by(genre: genre_name)

      movie = Movie.new(
        title: movie_details['title'],
        year: movie_details['release_date'].split('-').first,
        description: movie_details['overview'],
        genre: genre,
        tmdb_id: tmdb_id
      )

      if movie.save
        Rails.logger.info("Movie fetched from TMDB and saved: #{movie.title}")

        cast_data = tmdb_api.fetch_cast(tmdb_id)

        puts "cast_data: #{cast_data.inspect}"

        cast_data.each do |cast_member_data|
          cast_member = Cast.find_or create_by(name: cast_member_data['name'])
          movie.casts << cast_member
        end

        return movie.id
      end
    else
      return nil
    end
  end




  def new
    @movie = Movie.new
    @movie.build_genre
    @movie.casts.build

    respond_to do |format|
      format.html
      format.json { render json: @movie }
    end
  end

  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie }
        format.json { render json: @movie, status: :created, location: @movie }
      else
        format.html { render 'new' }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @movie = Movie.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @movie }
    end
  end

  def update
    @movie = Movie.find(params[:id])

    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie }
        format.json { render json: @movie }
      else
        format.html { render 'edit' }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to movies_path }
      format.json { head :no_content }
    end
  end

  def movie_cast
    @movie = Movie.find(params[:movie_id])
    @cast = Cast.find(params[:cast_id])
    @movies = @cast.movies
  end

  def movies_by_genre
    @genre = Genre.find(params[:id])
    @movies = @genre.movies
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :year, :description, :genre_id, cast_ids: [], casts_attributes: [:id, :name, :dob], genre_attributes: [:id, :genre])
  end
end

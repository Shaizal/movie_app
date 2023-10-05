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
      movie = Movie.find_by(title: params[:search])

      if movie
        redirect_to movie_path(movie.id)
      else
        tmdb_api = TmdbApi.new
        movie_details = tmdb_api.fetch_movie(params[:search])

        if movie_details && movie_details['title']
          genre_mapping = tmdb_api.fetch_genre_mapping

          genre_id = movie_details['genre_ids'][0]

          genre_name = genre_mapping[genre_id] || 'Unknown'

          genre = Genre.find_by(genre: genre_name) || Genre.create(genre: genre_name)

          movie = Movie.new(
            title: movie_details['title'],
            year: movie_details['release_date'].split('-').first,
            description: movie_details['overview'],
            genre: genre
          )

          if movie.save
            Rails.logger.info("Movie fetched from TMDB and saved: #{movie.title}")
            Rails.logger.info("Movie details from TMDB: #{movie_details.inspect}")

            cast_data = tmdb_api.fetch_cast(movie_details['id'])

            cast_data.each do |cast_member_data|
              cast_member = Cast.find_by(name: cast_member_data['name'])

              unless cast_member
                cast_member = Cast.create(name: cast_member_data['name'])
              end

              movie.casts << cast_member
            end

            redirect_to movie_path(movie.id)
          else
            Rails.logger.error("Error saving movie: #{movie.errors.full_messages}")
          end
        else
          Rails.logger.error("Error fetching movie from TMDb.")
        end
      end
    else
      @movies = Movie.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @movie }
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
    params.require(:movie).permit(:title, :year, :description, :genre_id, cast_ids:[],  casts_attributes: [:id, :name, :dob], genre_attributes: [:id, :genre])
  end

end

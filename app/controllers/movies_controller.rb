class MoviesController < ApplicationController

  def show
    @movie = Movie.find(params[:id])
  end

  def index
    if params[:search].present?
      search_terms = params[:search].split(/\s+/) # Split the search query into words
      conditions = search_terms.map { |term| "title ILIKE ?" }.join(" OR ")
      search_values = search_terms.map { |term| "%#{term}%" }

      @movies = Movie.where(conditions, *search_values)
    else
      @movies = Movie.all
    end
  end

  def new
    @movie = Movie.new
    @movie.build_genre  # Build the nested genre attributes
    @movie.casts.build  # Build a nested cast attribute for new actors
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to @movie
    else
      render 'new'
    end
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update(movie_params)
      redirect_to @movie
    else
      render 'edit'
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path
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

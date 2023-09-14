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
      search_terms = params[:search].split(/\s+/)
      conditions = search_terms.map { |term| "title ILIKE ?" }.join(" OR ")
      search_values = search_terms.map { |term| "%#{term}%" }

      @movies = Movie.where(conditions, *search_values)
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

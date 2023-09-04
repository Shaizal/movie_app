class AddGenreToMovies < ActiveRecord::Migration[7.0]
  def change
    add_reference :movies, :genre, null: false, foreign_key: true
  end
end

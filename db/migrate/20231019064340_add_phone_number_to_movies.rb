class AddPhoneNumberToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :phone_number, :text
  end
end

class RemovePhoneNumberFromMovies < ActiveRecord::Migration[7.0]
  def change
    remove_column :movies, :phone_number, :text
  end
end

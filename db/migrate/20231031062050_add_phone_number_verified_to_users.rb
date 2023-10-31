class AddPhoneNumberVerifiedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number_verified, :boolean
  end
end

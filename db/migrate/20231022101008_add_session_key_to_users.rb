class AddSessionKeyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :session_key, :string
  end
end

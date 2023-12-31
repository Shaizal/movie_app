class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Add first_name and last_name fields to the User model
  validates :first_name, presence: true
  validates :last_name, presence: true
end

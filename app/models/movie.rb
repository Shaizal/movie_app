class Movie < ApplicationRecord
  attr_accessor :loaded
  has_many :movie_casts, dependent: :destroy
  has_many :casts, through: :movie_casts
  belongs_to :genre
  validates :title, presence: true
  accepts_nested_attributes_for :genre


  def casts_attributes=(cast_attributes)
    cast_attributes.each do |cast_attribute|
      cast = Cast.find_or_create_by(name: cast_attribute["name"])
      cast.dob = cast_attribute["dob"] if cast_attribute["dob"].present?
      self.casts << cast
    end
  end



end

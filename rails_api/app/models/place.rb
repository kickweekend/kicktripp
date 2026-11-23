class Place < ApplicationRecord
  belongs_to :destination
  has_many :activities, dependent: :restrict_with_error
  validates :name, :category, presence: true
end

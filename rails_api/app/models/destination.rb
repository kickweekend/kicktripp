class Destination < ApplicationRecord
  belongs_to :trip
  has_many :places, dependent: :restrict_with_error
  validates :country, :city, :arrival_on, :departure_on, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate do
    if arrival_on && departure_on
      errors.add(:departure_on, "must be on or after arrival_on") if departure_on < arrival_on
      unless trip&.covers_date?(arrival_on) && trip&.covers_date?(departure_on)
        errors.add(:base, "destination dates must be inside the trip")
      end
    end
  end
end

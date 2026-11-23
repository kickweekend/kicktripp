class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :activity, optional: true
  validates :title, :category, :currency, :spent_on, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000_000_000 }
  validate do
    errors.add(:currency, "must equal trip currency") if trip && currency != trip.currency
    errors.add(:spent_on, "must be inside the trip") if spent_on && !trip&.covers_date?(spent_on)
    if activity && (activity.trip_id != trip_id || activity.deleted?)
      errors.add(:activity, "must be a visible activity of this trip")
    end
  end
end

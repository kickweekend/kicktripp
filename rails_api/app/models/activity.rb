class Activity < ApplicationRecord
  belongs_to :trip
  belongs_to :place, optional: true
  has_many :expenses, dependent: :restrict_with_error
  has_many :participations, dependent: :restrict_with_error
  scope :visible, -> { where(deleted: false) }
  validates :title, :starts_at, :ends_at, presence: true
  validates :status, inclusion: { in: %w[planned completed cancelled] }
  validate do
    errors.add(:place, "must belong to this trip") if place && place.destination.trip_id != trip_id
    if starts_at && ends_at
      errors.add(:ends_at, "must be on or after starts_at") if ends_at < starts_at
      unless trip&.covers_time?(starts_at) && trip&.covers_time?(ends_at)
        errors.add(:base, "activity dates must be inside the trip")
      end
    end
  end
  def mark_deleted
    update(deleted: true)
  end
end

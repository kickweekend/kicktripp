class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :activity
  scope :visible, -> { joins(activity: :trip).where(activities: { deleted: false }, trips: { deleted: false }) }
  validates :user_id, uniqueness: { scope: :activity_id }
  validates :read, :invited, inclusion: { in: [true, false] }
  validate do
    errors.add(:activity, "must be visible") if activity && (activity.deleted? || activity.trip.deleted?)
  end
end

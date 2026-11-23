class Trip < ApplicationRecord
  belongs_to :user
  has_many :destinations, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error
  has_many :expenses, dependent: :restrict_with_error
  scope :visible, -> { where(deleted: false) }
  validates :title, :starts_on, :ends_on, :currency, :time_zone, presence: true
  validates :currency, format: { with: /\A[A-Z]{3}\z/ }
  validates :budget_amount, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000_000_000 }
  validate :consistent_plan

  def consistent_plan
    zone = ActiveSupport::TimeZone[time_zone]
    errors.add(:time_zone, "is unknown") unless zone
    return unless starts_on && ends_on
    errors.add(:ends_on, "must be on or after starts_on") if ends_on < starts_on
    if persisted?
      if destinations.any? { |d| d.arrival_on < starts_on || d.departure_on > ends_on }
        errors.add(:base, "dates exclude an existing destination")
      end
      if zone && activities.any? { |a| !covers_time?(a.starts_at) || !covers_time?(a.ends_at) }
        errors.add(:base, "dates exclude an existing activity")
      end
      errors.add(:currency, "differs from existing expenses") if expenses.where.not(currency: currency).exists?
      if expenses.any? { |e| !covers_date?(e.spent_on) }
        errors.add(:base, "dates exclude an existing expense")
      end
    end
  end

  def covers_date?(date)
    date && starts_on && ends_on && (starts_on..ends_on).cover?(date)
  end

  def covers_time?(time)
    zone = ActiveSupport::TimeZone[time_zone]
    zone && time && covers_date?(time.in_time_zone(zone).to_date)
  end
  def mark_deleted
    update(deleted: true)
  end
end

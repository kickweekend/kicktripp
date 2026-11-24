module Kicktripp
  class Expense < Sequel::Model(DB[:expenses])
    include ModelSupport
    API_FIELDS = %i[id trip_id activity_id title category amount currency spent_on created_at updated_at].freeze
    many_to_one :trip, class: "Kicktripp::Trip"
    many_to_one :activity, class: "Kicktripp::Activity"
    def validate
      super
      validates_presence %i[trip_id title category currency spent_on]
      money_validation(:amount)
      errors.add(:currency, "must equal trip currency") unless trip && currency == trip.currency
      errors.add(:spent_on, "must be inside the trip") unless trip&.covers_date?(spent_on)
      if activity_id && (!activity || activity.trip_id != trip_id || activity.deleted)
        errors.add(:activity_id, "must be a visible activity of this trip")
      end
    end
  end
end

module Kicktripp
  class Destination < Sequel::Model(DB[:destinations])
    include ModelSupport
    API_FIELDS = %i[id trip_id country city arrival_on departure_on position created_at updated_at].freeze
    many_to_one :trip, class: "Kicktripp::Trip"
    one_to_many :places, class: "Kicktripp::Place"
    def validate
      super
      validates_presence %i[trip_id country city arrival_on departure_on]
      validates_integer :position
      errors.add(:position, "must be nonnegative") unless position && position >= 0
      if arrival_on && departure_on
        errors.add(:departure_on, "must be on or after arrival_on") if departure_on < arrival_on
        errors.add(:base, "dates must be inside the trip") unless trip&.covers_date?(arrival_on) && trip&.covers_date?(departure_on)
      end
    end
  end
end

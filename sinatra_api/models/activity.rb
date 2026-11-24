module Kicktripp
  class Activity < Sequel::Model(DB[:activities])
    include ModelSupport
    API_FIELDS = %i[id trip_id place_id title starts_at ends_at notes status deleted created_at updated_at].freeze
    many_to_one :trip, class: "Kicktripp::Trip"
    many_to_one :place, class: "Kicktripp::Place"
    one_to_many :expenses, class: "Kicktripp::Expense"
    one_to_many :participations, class: "Kicktripp::Participation"
    dataset_module do
      def visible
        where(deleted: false, trip_id: Trip.visible.select(:id))
      end
      def by_title(value) = where(Sequel.ilike(:title, "%#{Kicktripp::DB[:trips].escape_like(value)}%"))
      def by_place(value) = where(place_id: Place.where(Sequel.ilike(:name, "%#{Kicktripp::DB[:trips].escape_like(value)}%")).select(:id))
    end
    def mark_deleted
      update(deleted: true)
    end

    def validate
      super
      validates_presence %i[trip_id title starts_at ends_at]
      validates_includes %w[planned completed cancelled], :status
      errors.add(:place_id, "must belong to this trip") if place_id && (!place || place.destination.trip_id != trip_id)
      if starts_at && ends_at
        errors.add(:ends_at, "must be on or after starts_at") if ends_at < starts_at
        errors.add(:base, "dates must be inside the trip") unless trip&.covers_time?(starts_at) && trip&.covers_time?(ends_at)
      end
    end
  end
end

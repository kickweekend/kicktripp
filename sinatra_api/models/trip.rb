module Kicktripp
  class Trip < Sequel::Model(DB[:trips])
    include ModelSupport
    API_FIELDS = %i[id user_id title description starts_on ends_on budget_amount currency time_zone deleted created_at updated_at].freeze
    many_to_one :user, class: "Kicktripp::User"
    one_to_many :destinations, class: "Kicktripp::Destination"
    one_to_many :activities, class: "Kicktripp::Activity"
    one_to_many :expenses, class: "Kicktripp::Expense"
    dataset_module do
      def visible = where(deleted: false)
      def by_title(value) = where(Sequel.ilike(:title, "%#{Kicktripp::DB[:trips].escape_like(value)}%"))
      def by_city(value)
        where(id: Destination.where(Sequel.ilike(:city, "%#{Kicktripp::DB[:trips].escape_like(value)}%")).select(:trip_id))
      end
    end

    def zone
      TZInfo::Timezone.get(time_zone || "UTC")
    rescue TZInfo::InvalidTimezoneIdentifier
      nil
    end

    def covers_date?(date)
      date && starts_on && ends_on && (starts_on..ends_on).cover?(date)
    end

    def covers_time?(time)
      time && zone && covers_date?(zone.utc_to_local(time.to_time.utc).to_date)
    end

    def mark_deleted
      update(deleted: true)
    end

    def validate
      super
      validates_presence %i[user_id title starts_on ends_on currency time_zone]
      errors.add(:user_id, "does not exist") unless user
      validates_format(/\A[A-Z]{3}\z/, :currency) if currency
      money_validation(:budget_amount)
      errors.add(:time_zone, "is unknown") unless zone
      return unless starts_on && ends_on
      errors.add(:ends_on, "must be on or after starts_on") if ends_on < starts_on
      return if new?
      if destinations.any? { |d| !covers_date?(d.arrival_on) || !covers_date?(d.departure_on) } || activities.any? { |a| !covers_time?(a.starts_at) || !covers_time?(a.ends_at) } || expenses.any? { |e| !covers_date?(e.spent_on) }
        errors.add(:base, "dates exclude existing records")
      end
      errors.add(:currency, "differs from existing expenses") if expenses_dataset.exclude(currency: currency).any?
    end
  end
end

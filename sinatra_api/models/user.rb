module Kicktripp
  class User < Sequel::Model(DB[:users])
    include ModelSupport
    API_FIELDS = %i[id name email interests bio created_at updated_at].freeze
    one_to_many :trips, class: "Kicktripp::Trip"
    one_to_many :participations, class: "Kicktripp::Participation"

    dataset_module do
      def by_name(value) = where(Sequel.ilike(:name, "%#{escape_like(value)}%"))
      def by_interests(value) = where(Sequel.ilike(:interests, "%#{escape_like(value)}%"))
    end

    def before_validation
      self.email = email.strip.downcase if email
      super
    end

    def validate
      super
      validates_presence %i[name email]
      validates_format(/\A[^\s@]+@[^\s@]+\.[^\s@]+\z/, :email) if email
      validates_unique :email
    end
  end
end

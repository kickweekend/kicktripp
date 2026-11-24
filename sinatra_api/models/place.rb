module Kicktripp
  class Place < Sequel::Model(DB[:places])
    include ModelSupport
    API_FIELDS = %i[id destination_id name category address description created_at updated_at].freeze
    many_to_one :destination, class: "Kicktripp::Destination"
    one_to_many :activities, class: "Kicktripp::Activity"
    def validate
      super
      validates_presence %i[destination_id name category]
      errors.add(:destination_id, "does not exist") unless destination
    end
  end
end

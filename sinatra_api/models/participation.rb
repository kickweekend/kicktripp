module Kicktripp
  class Participation < Sequel::Model(DB[:participations])
    include ModelSupport
    API_FIELDS = %i[id user_id activity_id read invited created_at updated_at].freeze
    many_to_one :user, class: "Kicktripp::User"
    many_to_one :activity, class: "Kicktripp::Activity"
    dataset_module do
      def visible = where(activity_id: Activity.visible.select(:id))
      def read = where(read: true)
      def unread = where(read: false)
    end
    def validate
      super
      validates_presence %i[user_id activity_id]
      validates_includes [true, false], :read
      validates_includes [true, false], :invited
      validates_unique %i[user_id activity_id]
      errors.add(:user_id, "does not exist") unless user
      errors.add(:activity_id, "must be visible") unless activity && !activity.deleted && !activity.trip.deleted
    end
  end
end

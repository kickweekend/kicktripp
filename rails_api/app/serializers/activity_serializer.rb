class ActivitySerializer
  def self.call(activity)
    activity.as_json(only: %i[id trip_id place_id title starts_at ends_at notes status deleted created_at updated_at])
  end
end

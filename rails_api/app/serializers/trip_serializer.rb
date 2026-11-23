class TripSerializer
  def self.call(trip)
    trip.as_json(only: %i[id user_id title description starts_on ends_on budget_amount currency time_zone deleted created_at updated_at])
  end
end

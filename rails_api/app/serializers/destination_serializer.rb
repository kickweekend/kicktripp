class DestinationSerializer
  def self.call(destination)
    destination.as_json(only: %i[id trip_id country city arrival_on departure_on position created_at updated_at])
  end
end

class PlaceSerializer
  def self.call(place)
    place.as_json(only: %i[id destination_id name category address description created_at updated_at])
  end
end

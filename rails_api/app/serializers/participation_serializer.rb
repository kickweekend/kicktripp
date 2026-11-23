class ParticipationSerializer
  def self.call(participation)
    participation.as_json(only: %i[id user_id activity_id read invited created_at updated_at])
  end
end

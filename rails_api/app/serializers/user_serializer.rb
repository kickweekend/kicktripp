class UserSerializer
  def self.call(user)
    user.as_json(only: %i[id name email interests bio created_at updated_at])
  end
end

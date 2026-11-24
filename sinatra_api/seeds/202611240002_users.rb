Sequel.seed(:development, :test) do
  def run
    Kicktripp::User.create(name: "Alex", email: "alex@example.test", interests: "museums food", bio: "Планирую путешествия по Японии")
    Kicktripp::User.create(name: "Maria", email: "maria@example.test", interests: "walking photography")
    Kicktripp::User.create(name: "Ivan", email: "ivan@example.test", interests: "hiking")
  end
end

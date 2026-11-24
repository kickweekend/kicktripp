Sequel.seed(:development, :test) do
  def run
    activity = Kicktripp::Activity.first(title: "Посещение музея")
    Kicktripp::Participation.create(user_id: Kicktripp::User.first(email: "maria@example.test").id, activity_id: activity.id, read: true, invited: true)
    Kicktripp::Participation.create(user_id: Kicktripp::User.first(email: "ivan@example.test").id, activity_id: activity.id, read: false, invited: false)
    activity = Kicktripp::Activity.first(title: "Прогулка")
    Kicktripp::Participation.create(user_id: Kicktripp::User.first(email: "maria@example.test").id, activity_id: activity.id, read: true, invited: false)
  end
end

Sequel.seed(:development, :test) do
  def run
    activity = Kicktripp::Activity.first(title: "Посещение музея")
    Kicktripp::Expense.create(trip_id: activity.trip_id, activity_id: activity.id, title: "Билет в музей", category: "tickets", amount: 1000, currency: "JPY", spent_on: Date.new(2027,4,2))
  end
end

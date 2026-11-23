return if Rails.env.test?

# Повторный запуск обновляет демонстрационные записи, не очищая чужие данные.
ActiveRecord::Base.transaction do
  owner = User.find_or_initialize_by(email: "alex@example.test")
  owner.update!(name: "Alex", interests: "museums food", bio: "Планирую путешествия по Японии")
  guest = User.find_or_initialize_by(email: "maria@example.test")
  guest.update!(name: "Maria", interests: "walking photography", bio: "Люблю городские прогулки")
  trip = owner.trips.find_or_initialize_by(title: "Япония 2027")
  trip.update!(starts_on: "2027-04-01", ends_on: "2027-04-10", currency: "JPY", budget_amount: 200000, time_zone: "Asia/Tokyo", deleted: false)
  destination = trip.destinations.find_or_initialize_by(city: "Tokyo")
  destination.update!(country: "Japan", arrival_on: "2027-04-01", departure_on: "2027-04-10", position: 0)
  place = destination.places.find_or_initialize_by(name: "Tokyo National Museum")
  place.update!(category: "museum", address: "Ueno Park")
  activity = trip.activities.find_or_initialize_by(title: "Посещение музея")
  activity.update!(place: place, starts_at: "2027-04-02T10:00:00+09:00", ends_at: "2027-04-02T12:00:00+09:00", status: "planned", deleted: false)
  expense = trip.expenses.find_or_initialize_by(title: "Билет в музей")
  expense.update!(activity: activity, category: "tickets", amount: 1000, currency: "JPY", spent_on: "2027-04-02")
  participation = activity.participations.find_or_initialize_by(user: guest)
  participation.update!(read: true, invited: true)
end
puts "kicktripp: demonstration data ready"

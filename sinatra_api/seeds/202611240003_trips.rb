Sequel.seed(:development, :test) do
  def run
    owner = Kicktripp::User.first(email: "alex@example.test")
    Kicktripp::Trip.create(user_id: owner.id, title: "Япония 2027", starts_on: Date.new(2027,4,1), ends_on: Date.new(2027,4,10), currency: "JPY", budget_amount: 200000, time_zone: "Asia/Tokyo")
    Kicktripp::Trip.create(user_id: owner.id, title: "Поездка в Казань", starts_on: Date.new(2027,6,1), ends_on: Date.new(2027,6,5), currency: "RUB", budget_amount: 15000, time_zone: "Europe/Moscow")
  end
end

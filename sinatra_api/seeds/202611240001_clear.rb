Sequel.seed(:development, :test) do
  def run
    Kicktripp::DB.run("TRUNCATE participations, expenses, activities, places, destinations, trips, users RESTART IDENTITY")
  end
end

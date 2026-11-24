require_relative "database_test_helper"

class ModelsTest < DatabaseTest
  def setup
    super
    create_plan
  end
  def test_database_constraints
    assert_raises(Sequel::UniqueConstraintViolation) do
      Kicktripp::DB.transaction(savepoint: true) { User.insert(name: "Duplicate", email: @owner.email.upcase, created_at: Time.now, updated_at: Time.now) }
    end
    assert_raises(Sequel::ForeignKeyConstraintViolation) do
      Kicktripp::DB.transaction(savepoint: true) { Trip.where(id: @trip.id).update(user_id: 99999999) }
    end
    assert_raises(Sequel::CheckConstraintViolation) do
      Kicktripp::DB.transaction(savepoint: true) { Expense.insert(trip_id: @trip.id, title: "Bad", category: "food", amount: -1, currency: "JPY", spent_on: Date.new(2027,4,2), created_at: Time.now, updated_at: Time.now) }
    end
  end
  def test_parent_timezone_cannot_exclude_activity
    @activity.update(starts_at: Time.iso8601("2027-04-01T00:30:00+09:00"), ends_at: Time.iso8601("2027-04-01T01:00:00+09:00"))
    @trip.time_zone = "UTC"
    refute @trip.valid?
  end
  def test_deleted_activity_does_not_accept_expenses_or_participation
    @activity.mark_deleted
    expense = Expense.new(trip_id: @trip.id, activity_id: @activity.id, title: "Bad", category: "tickets", amount: 1, currency: "JPY", spent_on: Date.new(2027,4,2))
    refute expense.valid?
    refute @participation.refresh.valid?
  end
  def test_dataset_methods_and_relations
    assert_equal 1, Trip.visible.by_title("jAP").by_city("tok").count
    assert_equal @trip.id, @activity.trip.id
    assert_equal @place.id, @activity.place.id
    assert_equal [@participation.id], Participation.visible.unread.select_map(:id)
  end
end

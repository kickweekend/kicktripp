require "test_helper"

class IntegrityTest < ActiveSupport::TestCase
  setup { create_plan }

  test "database enforces uniqueness foreign keys and nonnegative expenses" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      User.transaction(requires_new: true) { User.insert_all!([{ name: "Duplicate", email: @owner.email.upcase }]) }
    end
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Trip.transaction(requires_new: true) { @trip.update_column(:user_id, 99999999) }
    end
    assert_raises(ActiveRecord::StatementInvalid) do
      Expense.transaction(requires_new: true) do
        Expense.insert_all!([{ trip_id: @trip.id, title: "Bad", category: "food", amount: -1, currency: "JPY", spent_on: "2027-04-02" }])
      end
    end
  end

  test "changing timezone cannot exclude a scheduled activity" do
    @activity.update!(starts_at: "2027-04-01T00:30:00+09:00", ends_at: "2027-04-01T01:00:00+09:00")
    assert_not @trip.update(time_zone: "UTC")
    assert @trip.errors.any?
  end

  test "required associations and deleted activity expenses are validated" do
    assert_not Participation.new(user: @guest).valid?
    @activity.update!(deleted: true)
    expense = @trip.expenses.new(title: "Bad", category: "tickets", amount: 1, currency: "JPY", spent_on: "2027-04-02", activity: @activity)
    assert_not expense.valid?
    assert_not @participation.reload.valid?
  end
end

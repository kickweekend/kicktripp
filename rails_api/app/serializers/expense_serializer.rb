class ExpenseSerializer
  def self.call(expense)
    expense.as_json(only: %i[id trip_id activity_id title category amount currency spent_on created_at updated_at])
  end
end

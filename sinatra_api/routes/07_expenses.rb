namespace "/api/v1" do
  get "/trips/:trip_id/expenses" do
    collection_json(expenses_scope)
  end

  get "/trips/:trip_id/expenses/:id" do
    json_response(record!(expenses_scope, params[:id]).to_api)
  end

  post "/trips/:trip_id/expenses" do
    expenses_scope
    expense = Kicktripp::Expense.new(input(:activity_id, :title, :category, :amount, :currency, :spent_on).merge(trip_id: current_trip.id))
    expense.save
    respond(expense.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/trips/:trip_id/expenses/:id") do
      expense = record!(expenses_scope, params[:id])
      expense.set(input(:activity_id, :title, :category, :amount, :currency, :spent_on))
      expense.save
      json_response(expense.refresh.to_api)
    end
  end

  delete "/trips/:trip_id/expenses/:id" do
    expense = record!(expenses_scope, params[:id])
    expense.destroy
    status 204
    body ""
  end
end

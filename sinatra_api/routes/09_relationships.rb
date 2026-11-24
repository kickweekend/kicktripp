namespace "/api/v1" do
  get "/activities" do
    scope = activities_scope
    scope = scope.by_title(params[:title]) if params[:title]
    scope = scope.by_place(params[:place]) if params[:place]
    scope = scope.where(status: params[:status]) if params[:status]
    if params[:on]
      date = date_filter
      records = scope.eager(:trip).order(:id).all.select { |a| a.trip.zone.utc_to_local(a.starts_at.to_time.utc).to_date == date }
      json_response(records.map(&:to_api))
    else
      collection_json(scope)
    end
  end
  get "/activities/:id" do
    json_response(record!(Kicktripp::Activity.visible, params[:id]).to_api)
  end

  get "/users/:user_id/participations" do
    collection_json(boolean_filter(boolean_filter(participations_scope, :read), :invited))
  end
  get "/activities/:activity_id/participations" do
    collection_json(boolean_filter(boolean_filter(participations_scope, :read), :invited))
  end
  get "/trips/:trip_id/activities/:activity_id/participations" do
    collection_json(boolean_filter(boolean_filter(participations_scope, :read), :invited))
  end
  get "/activities/:activity_id/users" do
    activity = record!(Kicktripp::Activity.visible, params[:activity_id])
    collection_json(filtered_users(Kicktripp::User.where(id: Kicktripp::Participation.where(activity_id: activity.id).select(:user_id))))
  end
  get "/trips/:trip_id/users" do
    ids = Kicktripp::Participation.visible.where(activity_id: Kicktripp::Activity.visible.where(trip_id: current_trip.id).select(:id)).select(:user_id)
    collection_json(filtered_users(Kicktripp::User.where(id: ids)))
  end
  get "/trips/:id/summary" do
    trip = record!(Kicktripp::Trip.visible, params[:id])
    total = trip.expenses_dataset.sum(:amount) || BigDecimal("0")
    json_response(trip_id: trip.id, currency: trip.currency, budget_amount: trip.budget_amount.to_s("F"),
      spent_amount: total.to_s("F"), remaining_amount: (trip.budget_amount - total).to_s("F"),
      destinations_count: trip.destinations_dataset.count, activities_count: trip.activities_dataset.visible.count)
  end

  # Аналоги read/unread из методички №4; основной контракт поддерживает фильтры.
  get("/participations_read") { collection_json(Kicktripp::Participation.visible.read) }
  get("/participations_unread") { collection_json(Kicktripp::Participation.visible.unread) }
end

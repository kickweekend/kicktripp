module Kicktripp
  module ApiHelpers
    def respond(data, code = 200)
      status code
      json_response(data)
    end

    def record!(scope, id)
      record = scope.where(id: id.to_i).first if id.to_s.match?(/\A[0-9]+\z/)
      unless record
        @not_found_response = { error: "not_found" }
        halt 404
      end
      record
    end

    def current_trip
      @current_trip ||= record!(Trip.visible, params[:trip_id])
    end

    def activities_scope
      params[:trip_id] ? Activity.visible.where(trip_id: current_trip.id) : Activity.visible
    end

    def destinations_scope
      Destination.where(trip_id: current_trip.id)
    end

    def places_scope
      destination = record!(destinations_scope, params[:destination_id])
      Place.where(destination_id: destination.id)
    end

    def expenses_scope
      Expense.where(trip_id: current_trip.id)
    end

    def participations_scope
      if params[:user_id]
        user = record!(User.dataset, params[:user_id])
        Participation.visible.where(user_id: user.id)
      elsif params[:activity_id]
        activity = record!(activities_scope, params[:activity_id])
        Participation.visible.where(activity_id: activity.id)
      else
        Participation.visible
      end
    end

    def input(*fields)
      unless defined?(@input)
        @input = if request.media_type == "application/json"
          JSON.parse(request.body.read)
        else
          request.params
        end
        halt 400, json_response(error: "bad_request", message: "JSON body must be an object") unless @input.is_a?(Hash)
      end
      fields.each_with_object({}) do |field, result|
        next unless @input.key?(field.to_s)
        value = @input[field.to_s]
        if %i[read invited].include?(field) && ![true, false].include?(value)
          halt 422, json_response(errors: { field => ["must be boolean"] })
        end
        if %i[starts_at ends_at].include?(field) && value
          valid = value.is_a?(String) && value.match?(/(?:Z|[+-]\d{2}:\d{2})\z/) && (Time.iso8601(value) rescue nil)
          halt 400, json_response(error: "bad_request", message: "#{field} must be ISO 8601 with timezone") unless valid
          value = Time.iso8601(value).utc
        end
        if %i[starts_on ends_on arrival_on departure_on spent_on].include?(field) && value
          value = Date.iso8601(value.to_s) rescue nil
        end
        result[field] = value
      end
    end

    def boolean_filter(scope, key)
      return scope unless params.key?(key.to_s)
      value = params[key.to_s]
      halt 400, json_response(error: "bad_request", message: "#{key} must be true or false") unless %w[true false].include?(value)
      scope.where(key => value == "true")
    end

    def date_filter
      Date.iso8601(params[:on])
    rescue ArgumentError
      halt 400, json_response(error: "bad_request", message: "on must be an ISO date")
    end

    def filtered_users(scope)
      scope = scope.by_name(params[:name]) if params[:name]
      scope = scope.by_interests(params[:interests]) if params[:interests]
      scope
    end

    def collection_json(scope)
      json_response(scope.order(:id).all.map(&:to_api))
    end
  end
end
helpers Kicktripp::ApiHelpers

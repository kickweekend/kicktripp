module Api
  module V1
    class TripsController < ApplicationController
      before_action :set_trip, only: %i[show update destroy mark_deleted summary]

      def index
        @trips = filtered_trips.order(:id).distinct
        render json: @trips.map { |trip| TripSerializer.call(trip) }
      end

      def show
        render json: TripSerializer.call(@trip)
      end

      def create
        @trip = trips_scope.new(trip_params)
        if @trip.save
          render json: TripSerializer.call(@trip), status: :created
        else
          render json: { errors: @trip.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @trip.update(trip_params)
          render json: TripSerializer.call(@trip)
        else
          render json: { errors: @trip.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @trip.mark_deleted
          head :no_content
        else
          render json: { errors: @trip.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def mark_deleted
        destroy
      end

      def summary
        total = @trip.expenses.sum(:amount)
        render json: { trip_id: @trip.id, currency: @trip.currency,
          budget_amount: @trip.budget_amount.to_s("F"), spent_amount: total.to_s("F"),
          remaining_amount: (@trip.budget_amount - total).to_s("F"),
          destinations_count: @trip.destinations.count, activities_count: @trip.activities.visible.count }
      end

      private

      def set_trip
        @trip = trips_scope.find(params[:id])
      end

      def trips_scope
        Trip.visible
      end
      def filtered_trips
        scope = text_filter(trips_scope, "trips.title", params[:title])
        scope = text_filter(scope.joins(:destinations), "destinations.city", params[:city]) if params[:city].present?
        scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
        if params[:on].present?
          date = Date.iso8601(params[:on]) rescue nil
          raise ActionController::BadRequest, "on must be an ISO date" unless date
          scope = scope.where("starts_on <= ? AND ends_on >= ?", date, date)
        end
        scope
      end
      def trip_params
        params.permit(:user_id, :title, :description, :starts_on, :ends_on, :budget_amount, :currency, :time_zone)
      end
    end
  end
end

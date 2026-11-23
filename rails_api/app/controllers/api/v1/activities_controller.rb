module Api
  module V1
    class ActivitiesController < ApplicationController
      before_action :set_activity, only: %i[show update destroy mark_deleted]

      def index
        @activities = filtered_activities.order(:id).distinct
        render json: @activities.map { |activity| ActivitySerializer.call(activity) }
      end

      def show
        render json: ActivitySerializer.call(@activity)
      end

      def create
        @activity = activities_scope.new(activity_params)
        if @activity.save
          render json: ActivitySerializer.call(@activity), status: :created
        else
          render json: { errors: @activity.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @activity.update(activity_params)
          render json: ActivitySerializer.call(@activity)
        else
          render json: { errors: @activity.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @activity.mark_deleted
          head :no_content
        else
          render json: { errors: @activity.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def mark_deleted
        destroy
      end

      private

      def set_activity
        @activity = activities_scope.find(params[:id])
      end

      def activities_scope
        params[:trip_id] ? trip.activities.visible : Activity.visible.joins(:trip).where(trips: { deleted: false })
      end
      def filtered_activities
        scope = text_filter(activities_scope, "activities.title", params[:title])
        scope = text_filter(scope.joins(:place), "places.name", params[:place]) if params[:place].present?
        scope = scope.where(status: params[:status]) if params[:status].present?
        if params[:on].present?
          date = Date.iso8601(params[:on]) rescue nil
          raise ActionController::BadRequest, "on must be an ISO date" unless date
          scope = scope.to_a.select { |a| a.starts_at.in_time_zone(a.trip.time_zone).to_date == date }
          return Activity.where(id: scope.map(&:id))
        end
        scope
      end
      def activity_params
        %i[starts_at ends_at].each do |field|
          next unless params[field].present?
          value = params[field].to_s
          unless value.match?(/(?:Z|[+-]\d{2}:\d{2})\z/) && (Time.iso8601(value) rescue nil)
            raise ActionController::BadRequest, "#{field} must be ISO 8601 with timezone"
          end
        end
        params.permit(:place_id, :title, :starts_at, :ends_at, :notes, :status)
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

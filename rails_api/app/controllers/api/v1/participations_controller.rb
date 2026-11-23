module Api
  module V1
    class ParticipationsController < ApplicationController
      before_action :set_participation, only: %i[show update destroy]

      def index
        @participations = filtered_participations.order(:id).distinct
        render json: @participations.map { |participation| ParticipationSerializer.call(participation) }
      end

      def show
        render json: ParticipationSerializer.call(@participation)
      end

      def create
        @participation = participations_scope.new(participation_params)
        if @participation.save
          render json: ParticipationSerializer.call(@participation), status: :created
        else
          render json: { errors: @participation.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @participation.update(participation_params)
          render json: ParticipationSerializer.call(@participation)
        else
          render json: { errors: @participation.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @participation.destroy
          head :no_content
        else
          render json: { errors: @participation.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_participation
        @participation = participations_scope.find(params[:id])
      end

      def participations_scope
        scope = Participation.visible
        if params[:user_id]
          scope = scope.where(user_id: User.find(params[:user_id]).id)
        elsif params[:activity_id]
          activities = params[:trip_id] ? trip.activities.visible : Activity.visible.joins(:trip).where(trips: { deleted: false })
          activity = activities.find(params[:activity_id])
          scope = scope.where(activity_id: activity.id)
        end
        scope
      end
      def filtered_participations
        boolean_filter(boolean_filter(participations_scope, :read), :invited)
      end
      def participation_params
        fields = action_name == "create" ? %i[user_id activity_id read invited] : %i[read invited]
        permitted = params.permit(*fields)
        if action_name == "create"
          permitted[:user_id] = params[:user_id] if params[:user_id]
          Activity.visible.joins(:trip).where(trips: { deleted: false }).find(permitted[:activity_id])
        end
        permitted
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

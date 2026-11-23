module Api
  module V1
    class DestinationsController < ApplicationController
      before_action :set_destination, only: %i[show update destroy]

      def index
        @destinations = filtered_destinations.order(:id).distinct
        render json: @destinations.map { |destination| DestinationSerializer.call(destination) }
      end

      def show
        render json: DestinationSerializer.call(@destination)
      end

      def create
        @destination = destinations_scope.new(destination_params)
        if @destination.save
          render json: DestinationSerializer.call(@destination), status: :created
        else
          render json: { errors: @destination.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @destination.update(destination_params)
          render json: DestinationSerializer.call(@destination)
        else
          render json: { errors: @destination.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @destination.destroy
          head :no_content
        else
          render json: { errors: @destination.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_destination
        @destination = destinations_scope.find(params[:id])
      end

      def filtered_destinations
        destinations_scope
      end

      def destinations_scope
        trip.destinations
      end
      def destination_params
        params.permit(:country, :city, :arrival_on, :departure_on, :position)
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

module Api
  module V1
    class PlacesController < ApplicationController
      before_action :set_place, only: %i[show update destroy]

      def index
        @places = filtered_places.order(:id).distinct
        render json: @places.map { |place| PlaceSerializer.call(place) }
      end

      def show
        render json: PlaceSerializer.call(@place)
      end

      def create
        @place = places_scope.new(place_params)
        if @place.save
          render json: PlaceSerializer.call(@place), status: :created
        else
          render json: { errors: @place.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @place.update(place_params)
          render json: PlaceSerializer.call(@place)
        else
          render json: { errors: @place.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @place.destroy
          head :no_content
        else
          render json: { errors: @place.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_place
        @place = places_scope.find(params[:id])
      end

      def filtered_places
        places_scope
      end

      def places_scope
        trip.destinations.find(params[:destination_id]).places
      end
      def place_params
        params.permit(:name, :category, :address, :description)
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

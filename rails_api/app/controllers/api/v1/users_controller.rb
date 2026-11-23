module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy]

      def index
        @users = filtered_users.order(:id).distinct
        render json: @users.map { |user| UserSerializer.call(user) }
      end

      def show
        render json: UserSerializer.call(@user)
      end

      def create
        @user = users_scope.new(user_params)
        if @user.save
          render json: UserSerializer.call(@user), status: :created
        else
          render json: { errors: @user.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: UserSerializer.call(@user)
        else
          render json: { errors: @user.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @user.destroy
          head :no_content
        else
          render json: { errors: @user.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = users_scope.find(params[:id])
      end

      def users_scope
        if params[:activity_id]
          activity = Activity.visible.joins(:trip).where(trips: { deleted: false }).find(params[:activity_id])
          User.where(id: activity.participations.select(:user_id))
        elsif params[:trip_id]
          User.where(id: Participation.visible.where(activity_id: trip.activities.visible.select(:id)).select(:user_id))
        else
          User.all
        end
      end
      def filtered_users
        scope = text_filter(users_scope, "users.name", params[:name])
        text_filter(scope, "users.interests", params[:interests])
      end
      def user_params
        params.permit(:name, :email, :interests, :bio)
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

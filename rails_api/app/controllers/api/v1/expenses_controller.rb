module Api
  module V1
    class ExpensesController < ApplicationController
      before_action :set_expense, only: %i[show update destroy]

      def index
        @expenses = filtered_expenses.order(:id).distinct
        render json: @expenses.map { |expense| ExpenseSerializer.call(expense) }
      end

      def show
        render json: ExpenseSerializer.call(@expense)
      end

      def create
        @expense = expenses_scope.new(expense_params)
        if @expense.save
          render json: ExpenseSerializer.call(@expense), status: :created
        else
          render json: { errors: @expense.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        if @expense.update(expense_params)
          render json: ExpenseSerializer.call(@expense)
        else
          render json: { errors: @expense.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def destroy
        if @expense.destroy
          head :no_content
        else
          render json: { errors: @expense.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_expense
        @expense = expenses_scope.find(params[:id])
      end

      def filtered_expenses
        expenses_scope
      end

      def expenses_scope
        trip.expenses
      end
      def expense_params
        params.permit(:activity_id, :title, :category, :amount, :currency, :spent_on)
      end

      def trip
        @trip ||= Trip.visible.find(params[:trip_id])
      end
    end
  end
end

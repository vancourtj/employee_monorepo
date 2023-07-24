# frozen_string_literal: true

module Api
  module V1
    class EmployeesController < ActionController::API
      before_action :find_employee, only: [:show, :update, :destroy]

      WHITELISTED_SEARCH_PARAMS = %i[
        department_eq
        title_eq
        salary_cents_eq
        salary_cents_lt
        salary_cents_gt
        salary_cents_lteq
        salary_cents_gteq
      ].freeze

      WHITELISTED_SORT_PARAMS = %i[
        date_of_employment
        salary_cents
      ].freeze

      DEFAULT_SORT = 'date_of_employment asc'.freeze

      def index
        @search = Employee.ransack(search_params[:query])
        @search.sorts = sortable_params

        @employees = @search.result

        render json: @employees
      end

      def show
        render json: @employee
      end

      def create
        @employee = Employee.new(employee_params)

        if @employee.save
          render json: @employee, status: :created
        else
          render json: { error: "Unable to create employee." }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: @employee
        else
          render json: { error: "Unable to update employee." }, status: :unprocessable_entity
        end
      end

      def destroy
        if @employee.destroy
          render json: { message: "Employee record successfully deleted" }, status: :ok
        else
          render json: { error: "Unable to delete employee." }, status: :unprocessable_entity
        end
      end

      private

      def search_params
        params.permit(query: WHITELISTED_SEARCH_PARAMS)
      end

      def sort_params
        params.permit(sort: WHITELISTED_SORT_PARAMS)
      end

      def sortable_params
        return DEFAULT_SORT if sort_params[:sort].nil? || sort_params[:sort].empty?

        sort_params[:sort].to_h.collect { |key, value| "#{key} #{value}" }
      end

      def employee_params
        params.require(:data).permit(:first_name, :last_name, :date_of_employment, :date_of_birth, :salary_cents,
                                     :title, :department)
      end

      def find_employee
        @employee = @employee = Employee.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "Employee with id #{params[:id]} not found" }, status: :not_found
      end
    end
  end
end

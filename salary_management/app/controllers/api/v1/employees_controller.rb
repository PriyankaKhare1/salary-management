module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        employees = Employee
          .includes(:salary)
          .search(params[:query])
          .by_department(params[:department])
          .by_country(params[:country])
          .by_designation(params[:designation])
          .order(:first_name, :last_name)
          .page(params[:page])
          .per(params[:per_page] || 25)

        render json: {
          employees: employees.map { |e| employee_json(e) },
          meta: {
            current_page: employees.current_page,
            total_pages: employees.total_pages,
            total_count: employees.total_count,
            per_page: employees.limit_value
          }
        }
      end

      def show
        employee = Employee.includes(:salary).find(params[:id])
        render json: employee_json(employee)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee_json(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        employee = Employee.find(params[:id])
        if employee.update(employee_params)
          render json: employee_json(employee)
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :first_name, :last_name, :email,
          :department, :designation, :country, :currency
        )
      end

      def employee_json(employee)
        {
          id: employee.id,
          first_name: employee.first_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          email: employee.email,
          department: employee.department,
          designation: employee.designation,
          country: employee.country,
          currency: employee.currency,
          salary: employee.salary ? {
            id: employee.salary.id,
            amount: employee.salary.amount,
            effective_date: employee.salary.effective_date
          } : nil,
          created_at: employee.created_at
        }
      end
    end
  end
end

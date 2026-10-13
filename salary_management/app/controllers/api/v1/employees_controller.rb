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
          employees: EmployeeSerializer.render_collection(employees),
          meta: {
            current_page: employees.current_page,
            total_pages:  employees.total_pages,
            total_count:  employees.total_count,
            per_page:     employees.limit_value
          }
        }
      end

      def show
        employee = Employee.includes(:salary).find(params[:id])
        render json: EmployeeSerializer.render(employee)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: EmployeeSerializer.render(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        employee = Employee.find(params[:id])
        if employee.update(employee_params)
          render json: EmployeeSerializer.render(employee)
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
    end
  end
end

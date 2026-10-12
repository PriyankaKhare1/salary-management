module Api
  module V1
    module Employees
      class SalariesController < ApplicationController
        def create
          employee = Employee.find(params[:employee_id])
          salary = employee.build_salary(salary_params)

          if salary.save
            render json: salary_json(salary), status: :created
          else
            render json: { errors: salary.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          employee = Employee.find(params[:employee_id])
          salary = employee.salary || employee.build_salary

          if salary.update(salary_params)
            render json: salary_json(salary)
          else
            render json: { errors: salary.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def salary_params
          params.require(:salary).permit(:amount, :effective_date)
        end

        def salary_json(salary)
          {
            id: salary.id,
            employee_id: salary.employee_id,
            amount: salary.amount,
            effective_date: salary.effective_date
          }
        end
      end
    end
  end
end

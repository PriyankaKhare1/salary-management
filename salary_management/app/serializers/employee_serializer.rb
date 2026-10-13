# Responsible for shaping Employee API responses consistently across all endpoints.
# Extracted from controller to keep controllers thin and ensure a single source
# of truth for the employee JSON representation.
class EmployeeSerializer
  def self.render(employee)
    {
      id:          employee.id,
      first_name:  employee.first_name,
      last_name:   employee.last_name,
      full_name:   employee.full_name,
      email:       employee.email,
      department:  employee.department,
      designation: employee.designation,
      country:     employee.country,
      currency:    employee.currency,
      salary:      salary_data(employee.salary),
      created_at:  employee.created_at
    }
  end

  def self.render_collection(employees)
    employees.map { |e| render(e) }
  end

  private_class_method def self.salary_data(salary)
    return nil unless salary

    {
      id:             salary.id,
      amount:         salary.amount,
      effective_date: salary.effective_date
    }
  end
end

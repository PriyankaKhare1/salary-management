class SalaryAnalyticsService
  # Fixed exchange rates to USD for cross-country comparison
  # Documented in architecture.md — deterministic, no external dependency
  EXCHANGE_RATES_TO_USD = {
    'INR' => 0.012,
    'USD' => 1.000,
    'GBP' => 1.270,
    'EUR' => 1.090,
    'CAD' => 0.740,
    'AUD' => 0.650
  }.freeze

  def summary
    Employee.joins(:salary)
            .group(:department)
            .select(
              :department,
              'COUNT(employees.id) as headcount',
              'SUM(salaries.amount) as total_payroll'
            )
            .map do |row|
              {
                department: row.department,
                headcount: row.headcount,
                total_payroll: row.total_payroll.to_f
              }
            end
  end

  def by_department
    Employee.joins(:salary)
            .group(:department)
            .average('salaries.amount')
            .map do |department, avg|
              {
                department: department,
                average_salary: avg.to_f.round(2)
              }
            end
            .sort_by { |r| r[:department] }
  end

  def by_country
    Employee.joins(:salary)
            .group(:country, :currency)
            .average('salaries.amount')
            .map do |(country, currency), avg|
              rate = EXCHANGE_RATES_TO_USD[currency] || 1.0
              {
                country: country,
                currency: currency,
                average_salary_local: avg.to_f.round(2),
                average_salary_usd: (avg.to_f * rate).round(2)
              }
            end
            .sort_by { |r| r[:country] }
  end

  def by_designation
    Employee.joins(:salary)
            .group(:designation)
            .average('salaries.amount')
            .map do |designation, avg|
              {
                designation: designation,
                average_salary: avg.to_f.round(2)
              }
            end
            .sort_by { |r| Employee::DESIGNATIONS.index(r[:designation]) || 99 }
  end
end

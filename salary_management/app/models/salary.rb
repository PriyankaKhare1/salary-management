class Salary < ApplicationRecord
  belongs_to :employee

  validates :amount, presence: true,
                     numericality: { greater_than: 0, message: "must be greater than 0" }
  validates :effective_date, presence: true
  validates :employee_id, uniqueness: { message: "already has a salary record" }
end

require 'rails_helper'

RSpec.describe Salary, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      salary = build(:salary)
      expect(salary).to be_valid
    end

    it 'is invalid without an amount' do
      salary = build(:salary, amount: nil)
      expect(salary).not_to be_valid
      expect(salary.errors[:amount]).to include("can't be blank")
    end

    it 'is invalid when amount is zero' do
      salary = build(:salary, amount: 0)
      expect(salary).not_to be_valid
      expect(salary.errors[:amount]).to include('must be greater than 0')
    end

    it 'is invalid when amount is negative' do
      salary = build(:salary, amount: -5000)
      expect(salary).not_to be_valid
      expect(salary.errors[:amount]).to include('must be greater than 0')
    end

    it 'is valid with the smallest representable positive amount' do
      salary = build(:salary, amount: 0.01)
      expect(salary).to be_valid
    end

    it 'is valid with a very large salary amount' do
      salary = build(:salary, amount: 999_999_999.99)
      expect(salary).to be_valid
    end

    it 'is invalid without an effective date' do
      salary = build(:salary, effective_date: nil)
      expect(salary).not_to be_valid
      expect(salary.errors[:effective_date]).to include("can't be blank")
    end

    it 'is invalid without an employee' do
      salary = build(:salary, employee: nil)
      expect(salary).not_to be_valid
      expect(salary.errors[:employee]).to be_present
    end

    it 'is invalid when employee already has a salary' do
      employee = create(:employee)
      create(:salary, employee: employee)
      duplicate = build(:salary, employee: employee)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:employee_id]).to include('already has a salary record')
    end

    it 'allows different employees to each have a salary' do
      emp1 = create(:employee)
      emp2 = create(:employee)
      create(:salary, employee: emp1)
      salary2 = build(:salary, employee: emp2)
      expect(salary2).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an employee' do
      salary = create(:salary)
      expect(salary.employee).to be_a(Employee)
    end

    it 'is destroyed when employee is destroyed' do
      employee = create(:employee)
      create(:salary, employee: employee)
      expect { employee.destroy }.to change(Salary, :count).by(-1)
    end
  end
end

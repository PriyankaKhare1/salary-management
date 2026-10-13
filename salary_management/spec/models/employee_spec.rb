require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      employee = build(:employee)
      expect(employee).to be_valid
    end

    it 'is invalid without a first name' do
      employee = build(:employee, first_name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without a last name' do
      employee = build(:employee, last_name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      employee = build(:employee, email: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a malformed email' do
      employee = build(:employee, email: 'not-an-email')
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to be_present
    end

    it 'is invalid with a duplicate email' do
      create(:employee, email: 'test@example.com')
      employee = build(:employee, email: 'test@example.com')
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to include('has already been taken')
    end

    it 'treats duplicate emails as case-insensitive' do
      create(:employee, email: 'test@example.com')
      employee = build(:employee, email: 'TEST@EXAMPLE.COM')
      expect(employee).not_to be_valid
    end

    it 'is invalid with an unrecognised department' do
      employee = build(:employee, department: 'InvalidDept')
      expect(employee).not_to be_valid
      expect(employee.errors[:department]).to be_present
    end

    it 'is invalid with an unrecognised designation' do
      employee = build(:employee, designation: 'VP')
      expect(employee).not_to be_valid
      expect(employee.errors[:designation]).to be_present
    end

    it 'is invalid with an unrecognised country' do
      employee = build(:employee, country: 'Mars')
      expect(employee).not_to be_valid
      expect(employee.errors[:country]).to be_present
    end

    it 'accepts all valid departments' do
      Employee::DEPARTMENTS.each do |dept|
        employee = build(:employee, department: dept)
        expect(employee).to be_valid, "Expected #{dept} to be a valid department"
      end
    end

    it 'accepts all valid designations' do
      Employee::DESIGNATIONS.each do |designation|
        employee = build(:employee, designation: designation)
        expect(employee).to be_valid, "Expected #{designation} to be a valid designation"
      end
    end
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      employee = build(:employee, first_name: 'Priya', last_name: 'Sharma')
      expect(employee.full_name).to eq('Priya Sharma')
    end

    it 'handles single-word names correctly' do
      employee = build(:employee, first_name: 'Madonna', last_name: '')
      expect(employee.full_name).to eq('Madonna ')
    end
  end

  describe 'scopes' do
    before do
      create(:employee, department: 'Engineering', country: 'India',
                        designation: 'Senior', currency: 'INR')
      create(:employee, department: 'Finance', country: 'USA',
                        designation: 'Junior', currency: 'USD')
    end

    it 'filters by department' do
      expect(Employee.by_department('Engineering').count).to eq(1)
    end

    it 'returns all employees when department filter is blank' do
      expect(Employee.by_department('').count).to eq(2)
    end

    it 'filters by country' do
      expect(Employee.by_country('India').count).to eq(1)
    end

    it 'returns all employees when country filter is blank' do
      expect(Employee.by_country(nil).count).to eq(2)
    end

    it 'filters by designation' do
      expect(Employee.by_designation('Senior').count).to eq(1)
    end

    it 'searches by first name' do
      create(:employee, first_name: 'Unique', last_name: 'Person')
      expect(Employee.search('unique').count).to eq(1)
    end

    it 'searches by partial name match' do
      create(:employee, first_name: 'Priyanka', last_name: 'Khare')
      expect(Employee.search('priy').count).to eq(1)
    end

    it 'returns all employees when search query is blank' do
      expect(Employee.search(nil).count).to eq(2)
    end
  end
end

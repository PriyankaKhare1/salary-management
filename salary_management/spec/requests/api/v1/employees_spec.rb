require 'rails_helper'

RSpec.describe 'Api::V1::Employees', type: :request do
  describe 'GET /api/v1/employees' do
    before { create_list(:employee, 3) }

    it 'returns a paginated list of employees' do
      get '/api/v1/employees'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['employees'].length).to eq(3)
      expect(json['meta']['total_count']).to eq(3)
    end

    it 'returns expected fields in response' do
      get '/api/v1/employees'
      json = JSON.parse(response.body)
      employee = json['employees'].first
      expect(employee.keys).to include('id', 'full_name', 'email', 'department',
                                       'designation', 'country', 'currency', 'salary')
    end

    it 'filters by department' do
      create(:employee, department: 'Engineering')
      get '/api/v1/employees', params: { department: 'Engineering' }
      json = JSON.parse(response.body)
      expect(json['employees'].all? { |e| e['department'] == 'Engineering' }).to be true
    end

    it 'filters by country' do
      create(:employee, country: 'India', currency: 'INR')
      get '/api/v1/employees', params: { country: 'India' }
      json = JSON.parse(response.body)
      expect(json['employees'].all? { |e| e['country'] == 'India' }).to be true
    end

    it 'filters by designation' do
      create(:employee, designation: 'Principal')
      get '/api/v1/employees', params: { designation: 'Principal' }
      json = JSON.parse(response.body)
      expect(json['employees'].all? { |e| e['designation'] == 'Principal' }).to be true
    end

    it 'searches by name' do
      create(:employee, first_name: 'Searchable', last_name: 'Person')
      get '/api/v1/employees', params: { query: 'searchable' }
      json = JSON.parse(response.body)
      expect(json['employees'].any? { |e| e['first_name'] == 'Searchable' }).to be true
    end

    it 'returns empty list when no employees match filter' do
      get '/api/v1/employees', params: { department: 'Engineering', country: 'Australia' }
      json = JSON.parse(response.body)
      expect(json['employees']).to be_empty
      expect(json['meta']['total_count']).to eq(0)
    end

    it 'paginates results' do
      create_list(:employee, 30)
      get '/api/v1/employees', params: { page: 1, per_page: 10 }
      json = JSON.parse(response.body)
      expect(json['employees'].length).to eq(10)
      expect(json['meta']['total_pages']).to be > 1
    end

    it 'returns correct meta for second page' do
      create_list(:employee, 30)
      get '/api/v1/employees', params: { page: 2, per_page: 10 }
      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(2)
    end
  end

  describe 'GET /api/v1/employees/:id' do
    let(:employee) { create(:employee) }

    it 'returns the employee with salary' do
      create(:salary, employee: employee)
      get "/api/v1/employees/#{employee.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(employee.id)
      expect(json['salary']).not_to be_nil
    end

    it 'returns salary as nil when not set' do
      get "/api/v1/employees/#{employee.id}"
      json = JSON.parse(response.body)
      expect(json['salary']).to be_nil
    end

    it 'returns 404 for non-existent employee' do
      get '/api/v1/employees/999999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/employees/:id/salary' do
    let(:employee) { create(:employee) }

    it 'creates a salary for an employee' do
      post "/api/v1/employees/#{employee.id}/salary",
           params: { salary: { amount: 75_000, effective_date: Date.today } }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['amount']).to eq('75000.0')
    end

    it 'returns errors for invalid salary amount' do
      post "/api/v1/employees/#{employee.id}/salary",
           params: { salary: { amount: -1000, effective_date: Date.today } }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
    end

    it 'returns errors when amount is zero' do
      post "/api/v1/employees/#{employee.id}/salary",
           params: { salary: { amount: 0, effective_date: Date.today } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns errors when effective date is missing' do
      post "/api/v1/employees/#{employee.id}/salary",
           params: { salary: { amount: 75_000 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /api/v1/employees/:id/salary' do
    let(:employee) { create(:employee) }

    it 'updates an existing salary' do
      create(:salary, employee: employee, amount: 50_000)
      put "/api/v1/employees/#{employee.id}/salary",
          params: { salary: { amount: 80_000, effective_date: Date.today } }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['amount']).to eq('80000.0')
    end

    it 'creates salary if none exists when updating' do
      put "/api/v1/employees/#{employee.id}/salary",
          params: { salary: { amount: 60_000, effective_date: Date.today } }
      expect(response).to have_http_status(:ok)
      expect(employee.reload.salary.amount).to eq(60_000)
    end
  end
end

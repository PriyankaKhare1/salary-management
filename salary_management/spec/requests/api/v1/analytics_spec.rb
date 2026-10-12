require 'rails_helper'

RSpec.describe 'Api::V1::Analytics', type: :request do
  before do
    eng_india = create(:employee, department: 'Engineering', country: 'India',
                                  currency: 'INR', designation: 'Senior')
    eng_usa   = create(:employee, department: 'Engineering', country: 'USA',
                                  currency: 'USD', designation: 'Lead')
    fin_uk    = create(:employee, department: 'Finance', country: 'UK',
                                  currency: 'GBP', designation: 'Junior')

    create(:salary, employee: eng_india, amount: 1_200_000)
    create(:salary, employee: eng_usa,   amount: 120_000)
    create(:salary, employee: fin_uk,    amount: 45_000)
  end

  describe 'GET /api/v1/analytics/summary' do
    it 'returns headcount and total payroll per department' do
      get '/api/v1/analytics/summary'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      departments = json.map { |r| r['department'] }
      expect(departments).to include('Engineering', 'Finance')
    end
  end

  describe 'GET /api/v1/analytics/by_department' do
    it 'returns average salary per department' do
      get '/api/v1/analytics/by_department'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      engineering = json.find { |r| r['department'] == 'Engineering' }
      expect(engineering['average_salary']).to be_a(Float)
    end
  end

  describe 'GET /api/v1/analytics/by_country' do
    it 'returns average salary in local currency and USD' do
      get '/api/v1/analytics/by_country'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      india = json.find { |r| r['country'] == 'India' }
      expect(india['average_salary_local']).to eq(1_200_000.0)
      expect(india['average_salary_usd']).to eq((1_200_000 * 0.012).round(2))
    end
  end

  describe 'GET /api/v1/analytics/by_designation' do
    it 'returns average salary per designation in correct order' do
      get '/api/v1/analytics/by_designation'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      designations = json.map { |r| r['designation'] }
      expect(designations).to include('Senior', 'Lead', 'Junior')
    end
  end
end

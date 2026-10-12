FactoryBot.define do
  factory :employee do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    email       { Faker::Internet.unique.email }
    department  { Employee::DEPARTMENTS.sample }
    designation { Employee::DESIGNATIONS.sample }
    country     { Employee::COUNTRIES.sample }
    currency    { Employee::CURRENCIES.sample }
  end
end

FactoryBot.define do
  factory :salary do
    association :employee
    amount         { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    effective_date { Date.today }
  end
end

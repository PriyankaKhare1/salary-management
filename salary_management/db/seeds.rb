# =============================================================================
# Seed Script — 10,000 Employees with Realistic Distributions
# =============================================================================
# Uses insert_all for bulk performance — avoids N+1 inserts
# Realistic salary ranges per country + designation
# Distributions mirror a real org: more juniors/mids than leads/principals
# =============================================================================

require 'faker'

puts "Clearing existing data..."
Salary.delete_all
Employee.delete_all

# --- Configuration -----------------------------------------------------------

DEPARTMENTS = %w[Engineering Product Design Finance HR Sales Marketing Operations].freeze

DESIGNATIONS = %w[Junior Mid Senior Lead Principal].freeze

COUNTRIES = [
  { name: 'India',     currency: 'INR' },
  { name: 'USA',       currency: 'USD' },
  { name: 'UK',        currency: 'GBP' },
  { name: 'Germany',   currency: 'EUR' },
  { name: 'Canada',    currency: 'CAD' },
  { name: 'Australia', currency: 'AUD' }
].freeze

# Realistic salary ranges per country per designation (annual, local currency)
SALARY_RANGES = {
  'India' => {
    'Junior'    => (400_000..700_000),
    'Mid'       => (700_000..1_200_000),
    'Senior'    => (1_200_000..2_000_000),
    'Lead'      => (2_000_000..3_000_000),
    'Principal' => (3_000_000..5_000_000)
  },
  'USA' => {
    'Junior'    => (60_000..90_000),
    'Mid'       => (90_000..130_000),
    'Senior'    => (130_000..180_000),
    'Lead'      => (180_000..230_000),
    'Principal' => (230_000..320_000)
  },
  'UK' => {
    'Junior'    => (28_000..42_000),
    'Mid'       => (42_000..65_000),
    'Senior'    => (65_000..90_000),
    'Lead'      => (90_000..120_000),
    'Principal' => (120_000..160_000)
  },
  'Germany' => {
    'Junior'    => (35_000..50_000),
    'Mid'       => (50_000..70_000),
    'Senior'    => (70_000..95_000),
    'Lead'      => (95_000..130_000),
    'Principal' => (130_000..170_000)
  },
  'Canada' => {
    'Junior'    => (50_000..70_000),
    'Mid'       => (70_000..100_000),
    'Senior'    => (100_000..140_000),
    'Lead'      => (140_000..180_000),
    'Principal' => (180_000..240_000)
  },
  'Australia' => {
    'Junior'    => (55_000..75_000),
    'Mid'       => (75_000..110_000),
    'Senior'    => (110_000..150_000),
    'Lead'      => (150_000..190_000),
    'Principal' => (190_000..260_000)
  }
}.freeze

# Realistic org shape — more juniors/mids, fewer principals
DESIGNATION_WEIGHTS = {
  'Junior'    => 25,
  'Mid'       => 35,
  'Senior'    => 25,
  'Lead'      => 10,
  'Principal' => 5
}.freeze

# Country distribution — India-heavy like a typical tech org
COUNTRY_WEIGHTS = {
  'India'     => 40,
  'USA'       => 25,
  'UK'        => 12,
  'Germany'   => 10,
  'Canada'    => 8,
  'Australia' => 5
}.freeze

# --- Helpers -----------------------------------------------------------------

def weighted_sample(weights_hash)
  total = weights_hash.values.sum
  r = rand(total)
  cumulative = 0
  weights_hash.each do |key, weight|
    cumulative += weight
    return key if r < cumulative
  end
end

# --- Seed --------------------------------------------------------------------

TOTAL = 10_000
BATCH_SIZE = 500

puts "Seeding #{TOTAL} employees in batches of #{BATCH_SIZE}..."

emails = Set.new
employees_data = []
salaries_data  = []

TOTAL.times do
  country_name = weighted_sample(COUNTRY_WEIGHTS)
  country      = COUNTRIES.find { |c| c[:name] == country_name }
  designation  = weighted_sample(DESIGNATION_WEIGHTS)
  department   = DEPARTMENTS.sample

  email = loop do
    e = Faker::Internet.unique.email
    break e unless emails.include?(e)
  end
  emails << email

  employees_data << {
    first_name:  Faker::Name.first_name,
    last_name:   Faker::Name.last_name,
    email:       email,
    department:  department,
    designation: designation,
    country:     country_name,
    currency:    country[:currency],
    created_at:  Time.current,
    updated_at:  Time.current
  }
end

# Bulk insert employees in batches
employees_data.each_slice(BATCH_SIZE).with_index do |batch, i|
  Employee.insert_all(batch)
  puts "  Inserted employees batch #{i + 1}/#{(TOTAL / BATCH_SIZE.to_f).ceil}"
end

puts "Seeding salaries..."

# Fetch all inserted employees and build salary data
Employee.find_each do |employee|
  range = SALARY_RANGES[employee.country][employee.designation]
  amount = rand(range)

  salaries_data << {
    employee_id:    employee.id,
    amount:         amount,
    effective_date: Faker::Date.between(from: 2.years.ago, to: Date.today),
    created_at:     Time.current,
    updated_at:     Time.current
  }
end

salaries_data.each_slice(BATCH_SIZE).with_index do |batch, i|
  Salary.insert_all(batch)
  puts "  Inserted salaries batch #{i + 1}/#{(TOTAL / BATCH_SIZE.to_f).ceil}"
end

puts ""
puts "✅ Seeding complete!"
puts "   Employees : #{Employee.count}"
puts "   Salaries  : #{Salary.count}"
puts ""
puts "Distribution by country:"
Employee.group(:country).count.sort_by { |_, v| -v }.each do |country, count|
  puts "  #{country.ljust(12)} #{count}"
end
puts ""
puts "Distribution by designation:"
Employee.group(:designation).count.each do |designation, count|
  puts "  #{designation.ljust(12)} #{count}"
end

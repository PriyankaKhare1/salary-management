class Employee < ApplicationRecord
  DEPARTMENTS = %w[Engineering Product Design Finance HR Sales Marketing Operations].freeze
  DESIGNATIONS = %w[Junior Mid Senior Lead Principal].freeze
  COUNTRIES = %w[India USA UK Germany Canada Australia].freeze
  CURRENCIES = %w[INR USD GBP EUR CAD AUD].freeze

  COUNTRY_CURRENCY_MAP = {
    'India'     => 'INR',
    'USA'       => 'USD',
    'UK'        => 'GBP',
    'Germany'   => 'EUR',
    'Canada'    => 'CAD',
    'Australia' => 'AUD'
  }.freeze

  has_one :salary, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :department, presence: true, inclusion: { in: DEPARTMENTS }
  validates :designation, presence: true, inclusion: { in: DESIGNATIONS }
  validates :country, presence: true, inclusion: { in: COUNTRIES }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }

  scope :by_department, ->(dept) { where(department: dept) if dept.present? }
  scope :by_country, ->(country) { where(country: country) if country.present? }
  scope :by_designation, ->(designation) { where(designation: designation) if designation.present? }
  scope :search, ->(query) {
    where("lower(first_name || ' ' || last_name) LIKE ? OR lower(email) LIKE ?",
          "%#{query.downcase}%", "%#{query.downcase}%") if query.present?
  }

  def full_name
    "#{first_name} #{last_name}"
  end
end

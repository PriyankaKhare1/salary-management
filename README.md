# Salary Management System — ACME HR Portal

A web-based salary management application for ACME org's HR team to manage salary data for 10,000 employees across multiple countries.

Built as part of the Incubyte engineering assessment.

---

## Live Demo

- **Frontend:** [Coming soon — Vercel]
- **Backend API:** [Coming soon — Railway]

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 7.1 (API mode) |
| Database | PostgreSQL |
| Frontend | React 18 |
| Charts | Recharts |
| Tests | RSpec + FactoryBot + Faker |

---

## Features

- View, search, and filter 10,000 employees by department, country, designation
- Set and update salary for any employee
- Analytics dashboard — average salary by department, country, designation
- Headcount and payroll summary
- Seed script with 10,000 realistic employees across 6 countries

---

## Project Structure

```
D:\Incubyte\
  docs/                        ← Requirements, architecture, tradeoffs, AI usage
  salary_management/           ← Rails API backend
  salary-management-ui/        ← React frontend
```

---

## Local Setup

### Prerequisites
- Ruby 3.2+
- Rails 7.1+
- PostgreSQL
- Node.js 18+

### Backend

```bash
cd salary_management
cp config/database.yml.example config/database.yml
# Update database.yml with your PostgreSQL credentials
bundle install
rails db:create db:migrate db:seed
bundle exec ruby bin/rails server -p 3001
```

### Frontend

```bash
cd salary-management-ui
npm install
npm start
```

Frontend runs on `http://localhost:3000`  
Backend API runs on `http://localhost:3001`

---

## Running Tests

```bash
cd salary_management
bundle exec rspec
```

37 examples, 0 failures

---

## Artifacts

See `docs/` for:
- `requirements.md` — Goal, scope, features, deliberate exclusions
- `architecture.md` — Data model, API design, technical decisions
- `tradeoffs.md` — Key trade-offs and reasoning
- `ai-usage.md` — How AI tools were used

---

## API Endpoints

```
GET    /api/v1/employees                    # Paginated list with search + filters
GET    /api/v1/employees/:id                # Employee detail with salary
POST   /api/v1/employees/:id/salary         # Set salary
PUT    /api/v1/employees/:id/salary         # Update salary
GET    /api/v1/analytics/summary            # Headcount + payroll by department
GET    /api/v1/analytics/by_department      # Average salary by department
GET    /api/v1/analytics/by_country         # Average salary by country (USD)
GET    /api/v1/analytics/by_designation     # Average salary by designation
```

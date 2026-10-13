# AI Usage — How I Used AI Tools in This Assessment

This document is a transparent account of where and how AI tools (Kiro/Claude) were used during this assessment, what I accepted, what I changed, and where I made independent decisions.

---

## Philosophy

I treat AI as a senior pair programmer — it can write fast and suggest patterns, but I am responsible for correctness, architecture decisions, and code quality. Every AI output was reviewed before committing.

---

## Actual Prompts Used

### 1. Requirements & Architecture
**Prompt used:**
> "Based on the assessment brief and HR team's clarifications, create a one-page requirements document. Include: goal, scope, features, what is deliberately left out and why, technical decisions. Make it clear this is for a single HR Manager persona, payroll is out of scope, currency is local with fixed rate normalisation."

**What I changed:** Added the "What Success Looks Like" section myself, including the line about commit history showing TDD — that was my own signal to evaluators.

---

### 2. Rails Models
**Prompt used:**
> "Create an Employee ActiveRecord model with validations for: first_name, last_name, email (unique, format validated), department (enum from fixed list), designation (enum), country (enum), currency. Add scopes for search, filter by department/country/designation. Use Rails 7.1."

**What I changed:**
- Added `COUNTRY_CURRENCY_MAP` constant — AI didn't include this, I added it for data integrity
- Changed scope implementation to handle blank params gracefully (return all records when filter is blank)

---

### 3. SalaryAnalyticsService
**Prompt used:**
> "Create a Rails service object SalaryAnalyticsService with 4 methods: summary (headcount + total payroll by dept), by_department (avg salary), by_country (avg in local + USD using fixed exchange rates), by_designation (avg, ordered by seniority). Use ActiveRecord GROUP BY queries, not Ruby-level aggregation."

**What I changed:**
- Fixed the designation ordering — AI used alphabetical sort, I changed it to use `DESIGNATIONS` index order (Junior → Mid → Senior → Lead → Principal)
- Added exchange rate constants as a named hash with a comment explaining the decision

---

### 4. Seed Script
**Prompt used:**
> "Create a Rails seed script for 10,000 employees. Use insert_all for performance. Realistic distributions: India 40%, USA 25%, UK 12%, Germany 10%, Canada 8%, Australia 5%. Designation distribution: Junior 25%, Mid 35%, Senior 25%, Lead 10%, Principal 5%. Salary ranges realistic per country and designation. Print summary after seeding."

**What I changed:**
- AI initially used `create` in a loop — I explicitly changed it to `insert_all` with batches
- Added the `Set` for email uniqueness tracking — AI's version had potential duplicates

---

### 5. React Frontend
**Prompt used:**
> "Create a React SPA with two pages: Dashboard (analytics charts using Recharts) and Employees (paginated table with search and filter). Use plain CSS, no Tailwind. API base URL from REACT_APP_API_URL env var. Include debounced search, loading states, error handling, and a modal for salary edit."

**What I changed:**
- Reviewed all components for accessibility — added `aria-label`, `role`, `aria-live` attributes
- Fixed the analytics dashboard — AI generated generic charts, I restructured to answer specific HR questions (avg by dept, avg by country in USD, headcount distribution, avg by designation)
- Removed unused `Legend` import and `totalPayroll` variable that caused ESLint build failure

---

### 6. RSpec Tests
**Prompt used:**
> "Write RSpec model specs for Employee and Salary, and request specs for employees and analytics endpoints. Include edge cases: duplicate email, invalid enums, zero/negative salary, empty filter results, pagination meta, 404 handling."

**What I changed:**
- Fixed the `0.001` amount test — AI expected it to be valid but our `decimal(15,2)` column rounds it to `0.00`. Changed to `0.01` which is the smallest valid amount
- Added `treats duplicate emails as case-insensitive` test — AI missed this edge case
- Added `creates salary if none exists when updating` test — important upsert behaviour

---

## Where I Overrode AI Suggestions

| AI Suggestion | What I Did Instead | Why |
|---|---|---|
| Use SQLite | Used PostgreSQL | Better analytics performance at 10k scale |
| Single Rails repo with ERB views | Rails API + React | Assessment requirement |
| Store salary history table | Current state only | Confirmed out of scope, keeps model clean |
| `create` in seed loop | `insert_all` bulk insert | 10k records in seconds not minutes |
| `employee_json` in controller | Extracted `EmployeeSerializer` | Single responsibility, thin controllers |
| Alphabetical designation order | Seniority-based order | More meaningful for HR analytics |
| Generic dashboard charts | Business-question-driven charts | HR Manager needs answers, not just data |

---

## Commit Discipline

Every commit was made by me with a meaningful message following conventional commit format (`feat:`, `test:`, `chore:`, `refactor:`, `fix:`, `docs:`). AI did not drive the commit structure — I broke work into logical increments to show the evolution of thinking.

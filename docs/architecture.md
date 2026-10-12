# Architecture — Employee Salary Management System

## Overview

A standard client-server web application with a Rails API backend and a React SPA frontend. Chosen for clear separation of concerns, independent testability of each layer, and alignment with the assessment requirements.

```
┌─────────────────────────────────────────────────────┐
│                   Browser (HR Manager)               │
│                                                      │
│   React SPA (Shadcn/ui + Recharts)                  │
│   - Employee List, Salary Form, Analytics Dashboard  │
└─────────────────────┬───────────────────────────────┘
                      │ HTTP / JSON (REST)
                      │
┌─────────────────────▼───────────────────────────────┐
│              Rails API (API mode)                    │
│                                                      │
│  Routes → Controllers → Services → Models           │
│                                                      │
│  EmployeesController   SalaryController             │
│  AnalyticsController                                │
│                                                      │
│  SalaryService (business logic, currency conversion) │
└─────────────────────┬───────────────────────────────┘
                      │ ActiveRecord
                      │
┌─────────────────────▼───────────────────────────────┐
│              PostgreSQL                              │
│                                                      │
│  employees     salaries                             │
└─────────────────────────────────────────────────────┘
```

---

## Data Model

### employees
| Column | Type | Notes |
|---|---|---|
| id | bigint PK | |
| first_name | string | |
| last_name | string | |
| email | string | unique |
| department | string | indexed |
| designation | string | indexed |
| country | string | indexed |
| currency | string | ISO 4217 e.g. INR, USD |
| created_at | datetime | |
| updated_at | datetime | |

### salaries
| Column | Type | Notes |
|---|---|---|
| id | bigint PK | |
| employee_id | bigint FK | indexed, unique (one active salary per employee) |
| amount | decimal(15,2) | in employee's local currency |
| effective_date | date | when this salary became active |
| created_at | datetime | |
| updated_at | datetime | |

---

## API Design

```
GET    /api/v1/employees              # paginated list, search + filter
GET    /api/v1/employees/:id          # employee detail with salary
POST   /api/v1/employees/:id/salary   # create or update salary
GET    /api/v1/analytics/summary      # headcount + payroll cost by dept
GET    /api/v1/analytics/by_department  # avg salary per department
GET    /api/v1/analytics/by_country     # avg salary per country (USD)
GET    /api/v1/analytics/by_designation # avg salary per designation
```

---

## Key Design Decisions

**Service object for salary logic**  
Currency conversion and salary calculations live in `SalaryService`, not in the controller. This keeps controllers thin and logic independently testable.

**One salary record per employee**  
Upsert pattern — creating a salary when none exists, updating when one does. Keeps the model simple without a history table.

**Fixed exchange rates**  
Defined as a constant in `SalaryService`. No external API dependency. Deterministic for testing.

**Pagination at the DB level**  
Using `kaminari` gem. Offset-based pagination is sufficient for an internal HR tool with predictable usage patterns.

**Indexes on filter columns**  
`department`, `country`, `designation`, and `employee_id` (on salaries) are indexed. Required for acceptable query performance at 10,000 rows.

**React as a pure presentation layer**  
All business logic stays in Rails. React only fetches data, renders it, and sends updates back. This keeps the frontend simple and the backend the single source of truth.

---

## Currency Normalisation

Fixed exchange rates to USD (as of assessment date):

| Currency | Rate to USD |
|---|---|
| INR | 0.012 |
| USD | 1.000 |
| GBP | 1.270 |
| EUR | 1.090 |
| CAD | 0.740 |
| AUD | 0.650 |

Used only in analytics endpoints for cross-country comparison. Stored salaries always remain in local currency.

---

## Performance Considerations

- 10,000 rows is not large for PostgreSQL — standard indexes are sufficient
- Analytics queries use GROUP BY with AVG/SUM — single queries, not N+1
- Seed script uses `insert_all` (bulk insert) for performance — not `create` in a loop
- Frontend list is paginated (25 per page) — never loads all 10k at once
- React Query used for client-side caching — analytics dashboard does not re-fetch on every tab switch

# Requirements Document — Employee Salary Management System

**Author:** Priyanka Khare  
**Date:** October 2026  
**Version:** 1.0

---

## Goal

Replace ACME org's Excel-based salary management process with a web application that allows the HR Manager to manage salary data for 10,000 employees across multiple countries — and answer meaningful questions about how the organisation pays its people.

---

## Problem

The HR team currently manages salary data for 10,000 employees across multiple countries using spreadsheets. This approach is error-prone, hard to search, impossible to analyse at scale, and creates no audit visibility. A purpose-built web application will eliminate these pain points.

---

## User Persona

**Primary:** HR Manager  
Single user. No employee self-service, no multi-role access required.

---

## Scope & Features

### Employee Management
- View, search, and filter the full list of 10,000 employees
- Filter by department, country, and designation
- Paginated list for performance at scale
- View individual employee profile

### Salary Management
- View current salary for any employee
- Add or update salary for an employee
- Store salary in local currency per country
- Salary is stored as current state — full revision history is not required

### Analytics — "How does ACME pay its people?"
The dashboard answers the key questions an HR Manager needs:
- Average salary by department
- Average salary by country (normalised to USD using fixed exchange rates)
- Salary distribution by designation/band
- Total headcount and total payroll cost per department

### Seed Data
- 10,000 employees seeded with realistic distributions across:
  - 6 countries (India, USA, UK, Germany, Canada, Australia)
  - 8 departments (Engineering, Product, Design, Finance, HR, Sales, Marketing, Operations)
  - 5 designation levels (Junior, Mid, Senior, Lead, Principal)
  - Salary ranges appropriate per country and designation

---

## Deliberately Left Out — and Why

| Feature | Reason |
|---|---|
| Payroll processing (payslips, tax, deductions) | Out of scope per assessment brief. A separate payroll system concern. |
| Salary revision history / audit trail | Not required per HR team confirmation. Adds schema complexity without immediate value. |
| Authentication / RBAC | Single HR Manager persona. No security boundary needed for this scope. |
| Employee self-service portal | Not in the primary persona. Separate product decision. |
| Live currency exchange rates | Adds external dependency and non-determinism. Fixed rates are sufficient for reporting. |
| CSV/Excel import | Manual data entry + seed script covers the scope. Import is a future enhancement. |
| Email notifications | No workflow triggers defined in scope. |
| Mobile responsiveness | HR Manager operates on desktop. Out of scope for v1. |

---

## Technical Decisions

| Decision | Choice | Reasoning |
|---|---|---|
| Backend | Ruby on Rails (API mode) | Primary stack, production-quality code |
| Database | PostgreSQL | Handles 10k+ records, strong query support for analytics |
| Frontend | React + Shadcn/ui | Assessment requirement. Clean, modern component library. |
| Charts | Recharts | Lightweight, composable, works well with React |
| Currency normalisation | Fixed exchange rates (hardcoded) | Deterministic, no external dependency |
| Testing | RSpec (backend) + Jest (frontend) | Standard for Rails + React ecosystems |

---

## What Success Looks Like

- HR Manager can find any employee in under 3 seconds
- Salary can be updated in 2 clicks
- Dashboard loads and renders analytics for 10,000 employees without perceptible lag
- Code is readable, tested, and maintainable by any engineer picking it up
- Commit history shows incremental, test-driven development — requirements before code, tests before features, refactor after green

---

## Out of Scope for v1 — Potential v2 Features

- Salary bands and band compliance alerting
- Bulk salary update (e.g., annual increment by %)
- Export to CSV/Excel
- Salary revision history
- Multi-user access with roles

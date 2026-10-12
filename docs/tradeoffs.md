# Trade-offs & Decisions

This document captures the key trade-offs made during design and implementation, and the reasoning behind each choice.

---

## 1. SQLite vs PostgreSQL

**Chose: PostgreSQL**

The assessment suggests SQLite as an option. I chose PostgreSQL because:
- The seed requirement is 10,000 employees — PostgreSQL handles concurrent reads and GROUP BY analytics queries significantly better at this scale
- It matches production-grade expectations for an 8+ years experience submission
- Deployment on Railway/Render provides managed PostgreSQL for free

Trade-off: Slightly more setup overhead. Worth it for correctness and performance.

---

## 2. Rails Full Stack vs Rails API + React

**Chose: Rails API mode + React**

Could have used Rails with ERB views (simpler, one repo). Chose the split because:
- Assessment explicitly requires ReactJS or NextJS for UI
- Separation makes each layer independently testable
- Demonstrates ability to design a proper API contract

Trade-off: Two codebases to manage. Mitigated by keeping React as a thin presentation layer.

---

## 3. Salary History vs Current State Only

**Chose: Current state only**

A full audit-aware temporal model (effective_date ranges, who changed what) would be the right production choice. Deliberately left out because:
- HR team confirmed it is not required for this scope
- Adds significant schema and query complexity
- Core value is in the current data and analytics, not history

Future path: Add a `salary_histories` table and soft-delete pattern when this becomes a requirement.

---

## 4. Live Exchange Rates vs Fixed Rates

**Chose: Fixed rates**

Live rates via an external API (Open Exchange Rates, etc.) would be more accurate. Fixed rates chosen because:
- Adds external dependency and failure mode
- Makes tests non-deterministic
- HR analytics is for trend understanding, not financial precision — fixed rates are sufficient

---

## 5. Authentication

**Chose: No authentication**

A real HR system would require auth. Left out because:
- Assessment confirmed single HR Manager persona, auth not required
- Avoids scope creep on a time-boxed exercise
- Documented explicitly so evaluators know it was a conscious decision, not an oversight

---

## 6. Pagination Strategy — Offset vs Cursor

**Chose: Offset-based pagination**

Cursor-based pagination is more performant for very large datasets with frequent inserts. Chose offset because:
- 10,000 records is a fixed seed — no concurrent inserts during use
- Offset pagination is simpler, well-supported by kaminari, and sufficient for this scale
- HR Manager usage pattern is predictable (not a high-traffic public API)

---

## 7. Bulk Seed Insert Strategy

**Chose: `insert_all` over `create` in loop**

Inserting 10,000 records one by one via ActiveRecord `create` would take minutes and trigger 10,000 callbacks. `insert_all` bypasses callbacks and inserts in bulk, completing in seconds.

Trade-off: Skips validations and callbacks. Acceptable for seed data where we control the input.

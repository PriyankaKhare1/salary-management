# Performance Considerations

## Scale Context

The system manages 10,000 employees — a fixed dataset with predictable growth. This is not a high-traffic public API; it is an internal HR tool used by a single HR Manager. Performance decisions are made accordingly.

---

## N+1 Query Prevention

The most common performance pitfall in Rails is the N+1 query — fetching associated records one by one in a loop.

**Problem scenario:**
```ruby
# BAD — triggers 1 query for employees + N queries for salaries
Employee.all.each { |e| e.salary.amount }
```

**Our solution — `includes(:salary)` on every employee query:**
```ruby
# GOOD — 2 queries total regardless of result size
Employee.includes(:salary).page(1).per(25)
```

This is applied consistently in `EmployeesController#index` and `#show`. With 10,000 employees paginated at 25 per page, this means 2 queries per request — not 26.

---

## Database Indexes

Indexes are defined in the migration for all filterable and searchable columns:

| Table | Column | Index Type | Reason |
|---|---|---|---|
| employees | email | unique | Uniqueness constraint + lookup |
| employees | department | standard | Filter queries |
| employees | country | standard | Filter queries |
| employees | designation | standard | Filter queries |
| salaries | employee_id | unique | FK + one-salary-per-employee constraint |

Without these indexes, filter queries on 10,000 rows would require full table scans.

---

## Analytics Queries

Analytics endpoints use single `GROUP BY` queries with `AVG` and `COUNT` aggregations — not application-level loops:

```ruby
# Single query — database does the aggregation
Employee.joins(:salary)
        .group(:department)
        .average('salaries.amount')
```

This is significantly faster than fetching all employees and computing averages in Ruby.

---

## Seed Performance

Inserting 10,000 records via ActiveRecord `create` in a loop would trigger 10,000 INSERT statements and all model callbacks — taking several minutes.

**Our approach — `insert_all` in batches of 500:**
```ruby
Employee.insert_all(batch)  # Single INSERT per batch, bypasses callbacks
```

This reduces seed time from ~5 minutes to ~10 seconds.

**Trade-off:** `insert_all` skips ActiveRecord validations and callbacks. Acceptable for seed data where we control the input — not acceptable for user-facing create endpoints.

---

## Pagination

The employee list is paginated at 25 records per page using `kaminari`. This ensures:
- The API never returns all 10,000 records in a single response
- Frontend renders quickly regardless of total dataset size
- Database queries are bounded with `LIMIT` and `OFFSET`

**Trade-off:** Offset-based pagination degrades at very large offsets (page 400 of 10,000 records). At 10,000 records this is not a concern. Cursor-based pagination would be the right choice at 1M+ records.

---

## What Was Not Optimised (and Why)

| Concern | Decision |
|---|---|
| Redis caching for analytics | Not needed — analytics queries run in <100ms at 10k rows |
| Database connection pooling config | Default Puma/Rails config is sufficient for single-user HR tool |
| CDN for static assets | React app is served via Vercel which handles this automatically |
| Background jobs for seed | Seed runs once — not worth the complexity |

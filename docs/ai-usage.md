# AI Usage — How I Used AI Tools in This Assessment

This document is a transparent account of where and how AI tools (Kiro/Claude) were used during this assessment, what I accepted, what I changed, and where I made independent decisions.

---

## Philosophy

I treat AI as a senior pair programmer — it can write fast and suggest patterns, but I am responsible for correctness, architecture decisions, and code quality. Every AI output was reviewed before committing.

---

## Where AI Was Used

### 1. Requirements & Architecture Documents
AI helped structure and draft these documents. I reviewed every line and made the following independent decisions:
- Chose PostgreSQL over SQLite (AI suggested both as options — I decided based on scale and production-quality expectations)
- Defined the analytics scope based on what an HR Manager actually needs, not just what was easy to build
- Wrote the "deliberately left out" section myself — these were my judgement calls

### 2. React Frontend
React is not my primary stack (Rails is). I used AI to generate the React components, API integration layer, and chart configurations. My contributions on the frontend:
- Defined the API contract (endpoints, response shapes) — React consumed what I designed
- Reviewed every component for correctness and accessibility
- Made layout and UX decisions (what goes on which screen, what filters matter)
- Identified and fixed issues in AI-generated code (e.g., N+1 fetch patterns, missing loading states)

### 3. Seed Script
AI generated the initial seed structure. I changed:
- Salary ranges per country and designation to be realistic (not random)
- Distribution ratios (more junior/mid than senior/lead — realistic org shape)
- Used `insert_all` instead of the loop AI initially generated

### 4. Test Structure
AI suggested test skeletons. I wrote the meaningful assertions — particularly:
- Edge cases for salary validations (negative amounts, missing employee)
- Analytics endpoint tests with known seed data to assert correct averages

---

## Where I Overrode AI Suggestions

| AI Suggestion | What I Did Instead | Why |
|---|---|---|
| Use SQLite | Used PostgreSQL | Better for analytics at 10k scale |
| Single Rails repo with ERB views | Rails API + React | Assessment requirement |
| Store salary history table | Current state only | Confirmed out of scope, keeps model clean |
| Generic bar charts for analytics | Business-question-driven charts | HR Manager needs answers, not just data |
| `create` in seed loop | `insert_all` bulk insert | Performance — 10k records in seconds not minutes |

---

## Commit Discipline

Every commit was made by me with a meaningful message. AI did not drive the commit structure — I broke work into logical increments to show the evolution of thinking, not just the final output.

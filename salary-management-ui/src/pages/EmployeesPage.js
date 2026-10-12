import { useState, useEffect, useCallback } from 'react';
import { getEmployees } from '../services/api';
import SalaryModal from '../components/SalaryModal';

const DEPARTMENTS = ['Engineering', 'Product', 'Design', 'Finance', 'HR', 'Sales', 'Marketing', 'Operations'];
const DESIGNATIONS = ['Junior', 'Mid', 'Senior', 'Lead', 'Principal'];
const COUNTRIES = ['India', 'USA', 'UK', 'Germany', 'Canada', 'Australia'];

const DESIGNATION_COLORS = {
  Junior: 'badge-gray',
  Mid: 'badge-blue',
  Senior: 'badge-green',
  Lead: 'badge-purple',
  Principal: 'badge-orange',
};

function formatSalary(amount, currency) {
  if (!amount) return '—';
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export default function EmployeesPage() {
  const [employees, setEmployees] = useState([]);
  const [meta, setMeta] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [query, setQuery] = useState('');
  const [department, setDepartment] = useState('');
  const [country, setCountry] = useState('');
  const [designation, setDesignation] = useState('');
  const [page, setPage] = useState(1);

  const [salaryEmployee, setSalaryEmployee] = useState(null);

  const fetchEmployees = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await getEmployees({ query, department, country, designation, page, per_page: 25 });
      setEmployees(res.data.employees);
      setMeta(res.data.meta);
    } catch {
      setError('Failed to load employees. Please try again.');
    } finally {
      setLoading(false);
    }
  }, [query, department, country, designation, page]);

  useEffect(() => {
    const timer = setTimeout(fetchEmployees, 300);
    return () => clearTimeout(timer);
  }, [fetchEmployees]);

  const handleFilterChange = (setter) => (e) => {
    setter(e.target.value);
    setPage(1);
  };

  return (
    <div>
      <div className="page-header">
        <h1>Employees</h1>
        <p>Manage salary data for all {meta.total_count?.toLocaleString() || '—'} employees</p>
      </div>

      <div className="card">
        <div className="filters-bar">
          <input
            className="search-input"
            type="search"
            placeholder="Search by name or email..."
            value={query}
            onChange={handleFilterChange(setQuery)}
            aria-label="Search employees"
          />
          <select className="filter-select" value={department} onChange={handleFilterChange(setDepartment)} aria-label="Filter by department">
            <option value="">All Departments</option>
            {DEPARTMENTS.map((d) => <option key={d} value={d}>{d}</option>)}
          </select>
          <select className="filter-select" value={country} onChange={handleFilterChange(setCountry)} aria-label="Filter by country">
            <option value="">All Countries</option>
            {COUNTRIES.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
          <select className="filter-select" value={designation} onChange={handleFilterChange(setDesignation)} aria-label="Filter by designation">
            <option value="">All Designations</option>
            {DESIGNATIONS.map((d) => <option key={d} value={d}>{d}</option>)}
          </select>
        </div>

        {error && <div className="alert alert-error" role="alert">{error}</div>}

        {loading ? (
          <div className="loading" aria-live="polite">Loading employees...</div>
        ) : employees.length === 0 ? (
          <div className="empty-state">No employees found matching your filters.</div>
        ) : (
          <>
            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Department</th>
                    <th>Designation</th>
                    <th>Country</th>
                    <th>Current Salary</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {employees.map((emp) => (
                    <tr key={emp.id}>
                      <td>
                        <div style={{ fontWeight: 500 }}>{emp.full_name}</div>
                        <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{emp.email}</div>
                      </td>
                      <td>{emp.department}</td>
                      <td>
                        <span className={`badge ${DESIGNATION_COLORS[emp.designation] || 'badge-gray'}`}>
                          {emp.designation}
                        </span>
                      </td>
                      <td>{emp.country}</td>
                      <td>
                        {emp.salary
                          ? formatSalary(emp.salary.amount, emp.currency)
                          : <span style={{ color: 'var(--text-muted)' }}>Not set</span>}
                      </td>
                      <td>
                        <button
                          className="btn btn-ghost"
                          style={{ padding: '5px 12px', fontSize: 13 }}
                          onClick={() => setSalaryEmployee(emp)}
                        >
                          {emp.salary ? 'Edit Salary' : 'Set Salary'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="pagination">
              <span>
                Showing {((page - 1) * 25) + 1}–{Math.min(page * 25, meta.total_count)} of {meta.total_count?.toLocaleString()} employees
              </span>
              <div className="pagination-controls">
                <button onClick={() => setPage(p => p - 1)} disabled={page === 1} aria-label="Previous page">
                  ← Prev
                </button>
                <button onClick={() => setPage(p => p + 1)} disabled={page >= meta.total_pages} aria-label="Next page">
                  Next →
                </button>
              </div>
            </div>
          </>
        )}
      </div>

      {salaryEmployee && (
        <SalaryModal
          employee={salaryEmployee}
          onClose={() => setSalaryEmployee(null)}
          onSaved={fetchEmployees}
        />
      )}
    </div>
  );
}

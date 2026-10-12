import { useState, useEffect } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend
} from 'recharts';
import {
  getAnalyticsSummary,
  getAnalyticsByDepartment,
  getAnalyticsByCountry,
  getAnalyticsByDesignation
} from '../services/api';

const COLORS = ['#2563eb', '#16a34a', '#9333ea', '#ea580c', '#0891b2', '#dc2626', '#65a30d', '#d97706'];

function formatUSD(value) {
  if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(1)}M`;
  if (value >= 1_000) return `$${(value / 1_000).toFixed(0)}K`;
  return `$${value}`;
}

function StatCard({ label, value, sub }) {
  return (
    <div className="stat-card">
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value}</div>
      {sub && <div className="stat-sub">{sub}</div>}
    </div>
  );
}

export default function DashboardPage() {
  const [summary, setSummary] = useState([]);
  const [byDept, setByDept] = useState([]);
  const [byCountry, setByCountry] = useState([]);
  const [byDesignation, setByDesignation] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchAll = async () => {
      setLoading(true);
      try {
        const [s, d, c, des] = await Promise.all([
          getAnalyticsSummary(),
          getAnalyticsByDepartment(),
          getAnalyticsByCountry(),
          getAnalyticsByDesignation(),
        ]);
        setSummary(s.data);
        setByDept(d.data);
        setByCountry(c.data);
        setByDesignation(des.data);
      } catch {
        setError('Failed to load analytics. Please try again.');
      } finally {
        setLoading(false);
      }
    };
    fetchAll();
  }, []);

  const totalEmployees = summary.reduce((sum, r) => sum + Number(r.headcount), 0);
  const totalPayroll = summary.reduce((sum, r) => sum + Number(r.total_payroll), 0);
  const topDept = [...summary].sort((a, b) => b.headcount - a.headcount)[0];

  if (loading) return <div className="loading" aria-live="polite">Loading dashboard...</div>;
  if (error) return <div className="alert alert-error" role="alert">{error}</div>;

  return (
    <div>
      <div className="page-header">
        <h1>Dashboard</h1>
        <p>How ACME pays its people — across departments, countries and designations</p>
      </div>

      {/* KPI Stats */}
      <div className="stats-grid">
        <StatCard
          label="Total Employees"
          value={totalEmployees.toLocaleString()}
          sub="With salary data"
        />
        <StatCard
          label="Total Annual Payroll"
          value={formatUSD(
            byCountry.reduce((sum, r) => sum + (r.average_salary_usd * 
              (summary.find(s => s.department)?.headcount || 1)), 0)
          )}
          sub="Across all countries"
        />
        <StatCard
          label="Largest Department"
          value={topDept?.department || '—'}
          sub={topDept ? `${topDept.headcount} employees` : ''}
        />
        <StatCard
          label="Countries"
          value={byCountry.length}
          sub="Active locations"
        />
      </div>

      {/* Charts */}
      <div className="charts-grid">
        {/* Avg Salary by Department */}
        <div className="card">
          <div className="card-title">Average Salary by Department (Local Currency)</div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={byDept} margin={{ top: 5, right: 10, left: 10, bottom: 60 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="department" tick={{ fontSize: 11 }} angle={-35} textAnchor="end" />
              <YAxis tickFormatter={(v) => v >= 1000 ? `${(v/1000).toFixed(0)}K` : v} tick={{ fontSize: 11 }} />
              <Tooltip formatter={(v) => v.toLocaleString()} />
              <Bar dataKey="average_salary" fill="#2563eb" radius={[4, 4, 0, 0]} name="Avg Salary" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Avg Salary by Country in USD */}
        <div className="card">
          <div className="card-title">Average Salary by Country (USD)</div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={byCountry} margin={{ top: 5, right: 10, left: 10, bottom: 40 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="country" tick={{ fontSize: 11 }} />
              <YAxis tickFormatter={formatUSD} tick={{ fontSize: 11 }} />
              <Tooltip formatter={(v) => `$${v.toLocaleString()}`} />
              <Bar dataKey="average_salary_usd" fill="#16a34a" radius={[4, 4, 0, 0]} name="Avg Salary (USD)" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Headcount by Department Pie */}
        <div className="card">
          <div className="card-title">Headcount by Department</div>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie
                data={summary}
                dataKey="headcount"
                nameKey="department"
                cx="50%"
                cy="50%"
                outerRadius={90}
                label={({ department, percent }) =>
                  `${department} ${(percent * 100).toFixed(0)}%`
                }
                labelLine={false}
              >
                {summary.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(v) => v.toLocaleString()} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Avg Salary by Designation */}
        <div className="card">
          <div className="card-title">Average Salary by Designation (Local Currency)</div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={byDesignation} margin={{ top: 5, right: 10, left: 10, bottom: 20 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="designation" tick={{ fontSize: 12 }} />
              <YAxis tickFormatter={(v) => v >= 1000 ? `${(v/1000).toFixed(0)}K` : v} tick={{ fontSize: 11 }} />
              <Tooltip formatter={(v) => v.toLocaleString()} />
              <Bar dataKey="average_salary" fill="#9333ea" radius={[4, 4, 0, 0]} name="Avg Salary" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}

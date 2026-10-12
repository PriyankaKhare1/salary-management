import { useState } from 'react';
import { createSalary, updateSalary } from '../services/api';

export default function SalaryModal({ employee, onClose, onSaved }) {
  const existing = employee.salary;
  const [amount, setAmount] = useState(existing?.amount || '');
  const [effectiveDate, setEffectiveDate] = useState(
    existing?.effective_date || new Date().toISOString().split('T')[0]
  );
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!amount || Number(amount) <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    setSaving(true);
    try {
      const payload = { amount: Number(amount), effective_date: effectiveDate };
      if (existing) {
        await updateSalary(employee.id, payload);
      } else {
        await createSalary(employee.id, payload);
      }
      onSaved();
      onClose();
    } catch (err) {
      const msgs = err.response?.data?.errors;
      setError(msgs ? msgs.join(', ') : 'Something went wrong. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="modal-title">
      <div className="modal">
        <div className="modal-header">
          <h2 id="modal-title">
            {existing ? 'Update Salary' : 'Set Salary'} — {employee.full_name}
          </h2>
          <button className="modal-close" onClick={onClose} aria-label="Close modal">×</button>
        </div>

        <p style={{ color: 'var(--text-muted)', marginBottom: 20, fontSize: 13 }}>
          Currency: <strong>{employee.currency}</strong> · Country: <strong>{employee.country}</strong>
        </p>

        {error && <div className="alert alert-error" role="alert">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="amount">Annual Salary ({employee.currency})</label>
            <input
              id="amount"
              type="number"
              min="1"
              step="0.01"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="e.g. 1200000"
              required
              autoFocus
            />
          </div>

          <div className="form-group">
            <label htmlFor="effective-date">Effective Date</label>
            <input
              id="effective-date"
              type="date"
              value={effectiveDate}
              onChange={(e) => setEffectiveDate(e.target.value)}
              required
            />
          </div>

          <div className="form-actions">
            <button type="button" className="btn btn-ghost" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary" disabled={saving}>
              {saving ? 'Saving...' : existing ? 'Update Salary' : 'Set Salary'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

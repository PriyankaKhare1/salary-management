import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3001/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Employees
export const getEmployees = (params) => api.get('/employees', { params });
export const getEmployee = (id) => api.get(`/employees/${id}`);
export const createEmployee = (data) => api.post('/employees', { employee: data });
export const updateEmployee = (id, data) => api.put(`/employees/${id}`, { employee: data });

// Salaries
export const createSalary = (employeeId, data) =>
  api.post(`/employees/${employeeId}/salary`, { salary: data });
export const updateSalary = (employeeId, data) =>
  api.put(`/employees/${employeeId}/salary`, { salary: data });

// Analytics
export const getAnalyticsSummary = () => api.get('/analytics/summary');
export const getAnalyticsByDepartment = () => api.get('/analytics/by_department');
export const getAnalyticsByCountry = () => api.get('/analytics/by_country');
export const getAnalyticsByDesignation = () => api.get('/analytics/by_designation');

export default api;

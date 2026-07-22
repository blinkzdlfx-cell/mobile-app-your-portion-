const API_BASE = '/api'

async function apiFetch(endpoint: string, options: RequestInit = {}) {
  const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers as Record<string, string> || {}),
  }

  const res = await fetch(`${API_BASE}${endpoint}`, { ...options, headers })
  const data = await res.json()

  if (!res.ok) throw new Error(data.message || `HTTP ${res.status}`)
  return data
}

export const api = {
  login: (username: string, password: string) =>
    apiFetch('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    }),

  getDashboard: () => apiFetch('/dashboard'),

  getVerificationRequests: (params?: Record<string, string>) => {
    const qs = params ? '?' + new URLSearchParams(params).toString() : ''
    return apiFetch(`/verification/requests${qs}`)
  },

  approveVerification: (requestId: string, userId: string, requestType: string) =>
    apiFetch('/verification/approve', {
      method: 'POST',
      body: JSON.stringify({ requestId, userId, requestType }),
    }),

  rejectVerification: (requestId: string, reason: string) =>
    apiFetch('/verification/reject', {
      method: 'POST',
      body: JSON.stringify({ requestId, reason }),
    }),

  getPendingProperties: (status = 'pending') =>
    apiFetch(`/properties/pending?status=${status}`),

  approveProperty: (propertyId: string) =>
    apiFetch('/properties/approve', {
      method: 'POST',
      body: JSON.stringify({ propertyId }),
    }),

  rejectProperty: (propertyId: string, reason: string) =>
    apiFetch('/properties/reject', {
      method: 'POST',
      body: JSON.stringify({ propertyId, reason }),
    }),

  getPendingProjects: (status = 'pending') =>
    apiFetch(`/projects/pending?status=${status}`),

  approveProject: (projectId: string) =>
    apiFetch('/projects/approve', {
      method: 'POST',
      body: JSON.stringify({ projectId }),
    }),

  rejectProject: (projectId: string, reason: string) =>
    apiFetch('/projects/reject', {
      method: 'POST',
      body: JSON.stringify({ projectId, reason }),
    }),
}

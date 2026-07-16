// API client for admin dashboard
const API_BASE = 'http://localhost:3000/api/admin';

// Helper function for making authenticated API calls
async function apiCall(endpoint, options = {}) {
    const url = `${API_BASE}${endpoint}`;
    
    const defaultOptions = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('adminToken') || ''}`, // For token auth
        },
        ...options,
    };
    
    try {
        const response = await fetch(url, defaultOptions);
        
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('API call failed:', error);
        throw error;
    }
}

// Admin API functions
export async function getDashboardStats() {
    return await apiCall('/dashboard');
}

export async function getVerificationRequests(filter = {}) {
    const queryParams = new URLSearchParams(filter).toString();
    return await apiCall(`/verification/requests?${queryParams}`);
}

export async function approveVerificationRequest(requestId, userId, requestType) {
    return await apiCall('/verification/approve', {
        method: 'POST',
        body: { requestId, userId, requestType },
    });
}

export async function rejectVerificationRequest(requestId, reason) {
    return await apiCall('/verification/reject', {
        method: 'POST',
        body: { requestId, reason },
    });
}

export async function getPendingProperties(filter = {}) {
    const queryParams = new URLSearchParams(filter).toString();
    return await apiCall(`/properties/pending?${queryParams}`);
}

export async function approveProperty(propertyId) {
    return await apiCall('/properties/approve', {
        method: 'POST',
        body: { propertyId },
    });
}

export async function rejectProperty(propertyId, reason) {
    return await apiCall('/properties/reject', {
        method: 'POST',
        body: { propertyId, reason },
    });
}

export async function getPendingProjects(filter = {}) {
    const queryParams = new URLSearchParams(filter).toString();
    return await apiCall(`/projects/pending?${queryParams}`);
}

export async function approveProject(projectId) {
    return await apiCall('/projects/approve', {
        method: 'POST',
        body: { projectId },
    });
}

export async function rejectProject(projectId, reason) {
    return await apiCall('/projects/reject', {
        method: 'POST',
        body: { projectId, reason },
    });
}

export async function login(username, password) {
    const response = await apiCall('/auth/login', {
        method: 'POST',
        body: { username, password },
    });
    
    if (response.token) {
        localStorage.setItem('adminToken', response.token);
        localStorage.setItem('adminUser', JSON.stringify(response.user));
    }
    
    return response;
}

export function logout() {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
}

export function isAuthenticated() {
    return !!localStorage.getItem('adminToken');
}

export function getCurrentUser() {
    const userStr = localStorage.getItem('adminUser');
    return userStr ? JSON.parse(userStr) : null;
}

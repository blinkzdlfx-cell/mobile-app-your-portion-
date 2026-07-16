// Main admin dashboard application
import { getDashboardStats, getVerificationRequests, approveVerificationRequest, rejectVerificationRequest, getPendingProperties, approveProperty, rejectProperty, getPendingProjects, approveProject, rejectProject, login, logout, isAuthenticated } from './api.js';

document.addEventListener('DOMContentLoaded', function() {
    // Initialize app
    initApp();
});

function initApp() {
    // Check authentication
    if (!isAuthenticated()) {
        showLoginScreen();
        return;
    }
    
    // Setup navigation
    setupNavigation();
    
    // Load dashboard by default
    loadDashboard();
}

function showLoginScreen() {
    document.body.innerHTML = `
        <div class="login-container">
            <div class="login-box">
                <h2>Admin Login</h2>
                <form id="loginForm">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" required>
                    </div>
                    <button type="submit" class="btn-primary">Login</button>
                    <div id="loginError" class="error-message" style="display: none;"></div>
                </form>
            </div>
        </div>
    `;
    
    document.getElementById('loginForm')?.addEventListener('submit', handleLogin);
}

function handleLogin(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    login(username, password)
        .then((response) => {
            console.log('Login successful:', response);
            initApp();
        })
        .catch((error) => {
            console.error('Login failed:', error);
            document.getElementById('loginError').textContent = error.message;
            document.getElementById('loginError').style.display = 'block';
        });
}

function setupNavigation() {
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const section = this.getAttribute('data-section');
            
            // Update navigation
            document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Show target section
            document.querySelectorAll('.page').forEach(page => page.classList.remove('active'));
            document.getElementById(section).classList.add('active');
            
            // Load content for target section
            loadSectionContent(section);
        });
    });
    
    // Logout button
    document.getElementById('logoutBtn')?.addEventListener('click', function() {
        logout();
        showLoginScreen();
    });
}

async function loadSectionContent(section) {
    try {
        switch(section) {
            case 'dashboard':
                await loadDashboard();
                break;
            case 'verification':
                await loadVerificationRequests();
                break;
            case 'properties':
                await loadProperties();
                break;
            case 'projects':
                await loadProjects();
                break;
        }
    } catch (error) {
        console.error(`Error loading ${section}:`, error);
        showToast(`Failed to load ${section}`, 'error');
    }
}

async function loadDashboard() {
    try {
        const stats = await getDashboardStats();
        
        document.getElementById('dashboard').innerHTML = `
            <h2>Dashboard Overview</h2>
            <div class="stats-grid">
                <div class="stat-card" onclick="navigateToSection('verification')">
                    <h3>Seller Requests</h3>
                    <p class="stat-number">${stats.pendingSellerRequests}</p>
                </div>
                <div class="stat-card" onclick="navigateToSection('verification')">
                    <h3>Trusted Member Requests</h3>
                    <p class="stat-number">${stats.pendingTrustedRequests}</p>
                </div>
                <div class="stat-card" onclick="navigateToSection('properties')">
                    <h3>Property Approvals</h3>
                    <p class="stat-number">${stats.pendingProperties}</p>
                </div>
                <div class="stat-card" onclick="navigateToSection('projects')">
                    <h3>Project Approvals</h3>
                    <p class="stat-number">${stats.pendingProjects}</p>
                </div>
            </div>
            
            <h2>Recent Actions</h2>
            <div class="actions-list" id="recentActions">
                <!-- Recent admin actions will be populated here -->
                <div class="empty-state">
                    <p>No recent actions to display</p>
                </div>
            </div>
        `;
    } catch (error) {
        console.error('Failed to load dashboard:', error);
        document.getElementById('dashboard').innerHTML = `
            <div class="empty-state">
                <p>Failed to load dashboard. Please try again.</p>
            </div>
        `;
    }
}

async function loadVerificationRequests() {
    try {
        let filter = {};
        
        const verificationType = document.getElementById('verificationTypeFilter')?.value;
        if (verificationType) {
            filter.requestType = verificationType;
        }
        
        const verificationStatus = document.getElementById('verificationStatusFilter')?.value;
        if (verificationStatus) {
            filter.status = verificationStatus;
        }
        
        const requests = await getVerificationRequests(filter);
        
        if (requests.length === 0) {
            document.getElementById('requestsList').innerHTML = `
                <div class="empty-state">
                    <p>No verification requests to display</p>
                </div>
            `;
            return;
        }
        
        document.getElementById('requestsList').innerHTML = requests.map(request => `
            <div class="request-card">
                <div class="request-header">
                    <div class="request-info">
                        <h3>${request.full_name}</h3>
                        <p>${request.email}</p>
                        <p class="request-type">${request.request_type} verification</p>
                    </div>
                    <div class="request-status status-${request.status}">${request.status}</div>
                </div>
                
                ${request.reason ? `<p class="rejection-reason"><strong>Reason:</strong> ${request.reason}</p>` : ''}
                
                ${request.status === 'pending' ? `
                    <div class="action-buttons">
                        <button class="btn-primary" onclick="approveVerificationRequest('${request.id}', '${request.user_id}', '${request.request_type}')">Approve</button>
                        <button class="btn-secondary" onclick="rejectVerificationRequest('${request.id}')">Reject</button>
                    </div>
                ` : ''}
            </div>
        `).join('');
        
        // Setup event listeners for action buttons
        setupRequestActionListeners();
    } catch (error) {
        console.error('Failed to load verification requests:', error);
        document.getElementById('requestsList').innerHTML = `
            <div class="empty-state">
                <p>Failed to load verification requests. Please try again.</p>
            </div>
        `;
    }
}

async function loadProperties() {
    try {
        const properties = await getPendingProperties();
        
        if (properties.length === 0) {
            document.getElementById('propertiesList').innerHTML = `
                <div class="empty-state">
                    <p>No pending properties to approve</p>
                </div>
            `;
            return;
        }
        
        document.getElementById('propertiesList').innerHTML = properties.map(property => `
            <div class="property-card">
                <div class="card-header">
                    <div class="card-info">
                        <h3>${property.title}</h3>
                        <p>${property.location}</p>
                        <p><strong>Price:</strong> $${property.price}</p>
                    </div>
                    <div class="card-status status-pending">Pending</div>
                </div>
                
                <div class="action-buttons">
                    <button class="btn-primary" onclick="approveProperty('${property.id}')">Approve</button>
                    <button class="btn-secondary" onclick="rejectProperty('${property.id}')">Reject</button>
                </div>
            </div>
        `).join('');
        
        // Setup event listeners for action buttons
        setupPropertyActionListeners();
    } catch (error) {
        console.error('Failed to load properties:', error);
        document.getElementById('propertiesList').innerHTML = `
            <div class="empty-state">
                <p>Failed to load properties. Please try again.</p>
            </div>
        `;
    }
}

async function loadProjects() {
    try {
        const projects = await getPendingProjects();
        
        if (projects.length === 0) {
            document.getElementById('projectsList').innerHTML = `
                <div class="empty-state">
                    <p>No pending projects to approve</p>
                </div>
            `;
            return;
        }
        
        document.getElementById('projectsList').innerHTML = projects.map(project => `
            <div class="project-card">
                <div class="card-header">
                    <div class="card-info">
                        <h3>${project.title}</h3>
                        <p>${project.description || 'No description available'}</p>
                        <p><strong>Goal:</strong> $${project.goal_amount}</p>
                        <p><strong>Raised:</strong> $${project.raised_amount}</p>
                    </div>
                    <div class="card-status status-pending">Pending</div>
                </div>
                
                <div class="action-buttons">
                    <button class="btn-primary" onclick="approveProject('${project.id}')">Approve</button>
                    <button class="btn-secondary" onclick="rejectProject('${project.id}')">Reject</button>
                </div>
            </div>
        `).join('');
        
        // Setup event listeners for action buttons
        setupProjectActionListeners();
    } catch (error) {
        console.error('Failed to load projects:', error);
        document.getElementById('projectsList').innerHTML = `
            <div class="empty-state">
                <p>Failed to load projects. Please try again.</p>
            </div>
        `;
    }
}

function navigateToSection(section) {
    document.querySelector(`.nav-btn[data-section="${section}"]`).click();
}

function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    
    const toastContainer = document.getElementById('toastContainer');
    toastContainer.appendChild(toast);
    
    setTimeout(() => {
        toast.remove();
    }, 3000);
}

// Setup verification request action listeners
function setupRequestActionListeners() {
    document.querySelectorAll('.request-card').forEach(card => {
        const approveBtn = card.querySelector('.btn-primary');
        const rejectBtn = card.querySelector('.btn-secondary');
        
        if (approveBtn) {
            approveBtn.addEventListener('click', async function() {
                const requestHeader = card.querySelector('.request-header');
                const requestId = this.getAttribute('data-id');
                const requestType = this.getAttribute('data-type');
                const userId = this.getAttribute('data-user-id');
                
                try {
                    await approveVerificationRequest(requestId, userId, requestType);
                    showToast('Verification request approved successfully', 'success');
                    // Reload the list
                    loadVerificationRequests();
                } catch (error) {
                    showToast('Failed to approve verification request', 'error');
                }
            });
        }
        
        if (rejectBtn) {
            rejectBtn.addEventListener('click', async function() {
                const requestId = this.getAttribute('data-id');
                showRejectionModal(requestId);
            });
        }
    });
}

// Setup property action listeners
function setupPropertyActionListeners() {
    document.querySelectorAll('.property-card').forEach(card => {
        const approveBtn = card.querySelector('.btn-primary');
        const rejectBtn = card.querySelector('.btn-secondary');
        
        if (approveBtn) {
            approveBtn.addEventListener('click', async function() {
                const propertyId = this.getAttribute('data-id');
                
                try {
                    await approveProperty(propertyId);
                    showToast('Property approved successfully', 'success');
                    // Reload the list
                    loadProperties();
                } catch (error) {
                    showToast('Failed to approve property', 'error');
                }
            });
        }
        
        if (rejectBtn) {
            rejectBtn.addEventListener('click', async function() {
                const propertyId = this.getAttribute('data-id');
                showRejectionModal(propertyId, 'property');
            });
        }
    });
}

// Setup project action listeners
function setupProjectActionListeners() {
    document.querySelectorAll('.project-card').forEach(card => {
        const approveBtn = card.querySelector('.btn-primary');
        const rejectBtn = card.querySelector('.btn-secondary');
        
        if (approveBtn) {
            approveBtn.addEventListener('click', async function() {
                const projectId = this.getAttribute('data-id');
                
                try {
                    await approveProject(projectId);
                    showToast('Project approved successfully', 'success');
                    // Reload the list
                    loadProjects();
                } catch (error) {
                    showToast('Failed to approve project', 'error');
                }
            });
        }
        
        if (rejectBtn) {
            rejectBtn.addEventListener('click', async function() {
                const projectId = this.getAttribute('data-id');
                showRejectionModal(projectId, 'project');
            });
        }
    });
}

// Global rejection modal functions
let currentRejectionId = null;
let currentRejectionType = null;

function showRejectionModal(id, type) {
    currentRejectionId = id;
    currentRejectionType = type;
    
    const modal = document.getElementById('actionModal');
    const title = document.getElementById('modalTitle');
    const message = document.getElementById('modalMessage');
    const rejectForm = document.getElementById('rejectForm');
    
    title.textContent = `Reject ${type === 'property' ? 'Property' : type === 'project' ? 'Project' : 'Verification'}`;
    message.textContent = `Are you sure you want to reject this ${type}?`;
    rejectForm.style.display = 'block';
    
    modal.classList.add('active');
    
    // Setup confirm button
    const confirmBtn = document.getElementById('modalConfirmBtn');
    confirmBtn.onclick = function() {
        const reason = document.getElementById('rejectionReason').value;
        if (currentRejectionType === 'verification') {
            rejectVerificationRequest(currentRejectionId, reason);
        } else if (currentRejectionType === 'property') {
            rejectProperty(currentRejectionId, reason);
        } else if (currentRejectionType === 'project') {
            rejectProject(currentRejectionId, reason);
        }
        
        hideRejectionModal();
    };
}

function hideRejectionModal() {
    const modal = document.getElementById('actionModal');
    modal.classList.remove('active');
    currentRejectionId = null;
    currentRejectionType = null;
    document.getElementById('rejectionReason').value = '';
}

// Setup modal event listeners
document.addEventListener('DOMContentLoaded', function() {
    const modalCancelBtn = document.getElementById('modalCancelBtn');
    if (modalCancelBtn) {
        modalCancelBtn.addEventListener('click', hideRejectionModal);
    }
    
    // Hide modal when clicking outside
    document.getElementById('actionModal')?.addEventListener('click', function(e) {
        if (e.target === this) {
            hideRejectionModal();
        }
    });
});

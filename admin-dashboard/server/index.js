require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const JWT_SECRET = process.env.JWT_SECRET;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '..')));

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    req.admin = decoded;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

app.post('/api/admin/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password are required' });
    }

    if (username !== process.env.ADMIN_USERNAME) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const valid = await bcrypt.compare(password, process.env.ADMIN_PASSWORD_HASH);
    if (!valid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ username, role: 'admin' }, JWT_SECRET, { expiresIn: '24h' });

    res.json({
      token,
      user: { username, role: 'admin' },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Login failed' });
  }
});

app.get('/api/admin/dashboard', authMiddleware, async (req, res) => {
  try {
    const [sellerReq, trustedReq, properties, projects] = await Promise.all([
      supabase.from('verification_requests').select('id', { count: 'exact', head: true }).eq('request_type', 'seller').eq('status', 'pending'),
      supabase.from('verification_requests').select('id', { count: 'exact', head: true }).eq('request_type', 'trusted_member').eq('status', 'pending'),
      supabase.from('properties').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
      supabase.from('kingdom_projects').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
    ]);

    res.json({
      pendingSellerRequests: sellerReq.count ?? 0,
      pendingTrustedRequests: trustedReq.count ?? 0,
      pendingProperties: properties.count ?? 0,
      pendingProjects: projects.count ?? 0,
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ message: 'Failed to load dashboard stats' });
  }
});

app.get('/api/admin/verification/requests', authMiddleware, async (req, res) => {
  try {
    let query = supabase
      .from('verification_requests')
      .select('*')
      .order('created_at', { ascending: false });

    if (req.query.requestType) {
      query = query.eq('request_type', req.query.requestType);
    }
    if (req.query.status) {
      query = query.eq('status', req.query.status);
    }

    const { data, error } = await query;
    if (error) throw error;

    res.json(data || []);
  } catch (error) {
    console.error('Verification requests error:', error);
    res.status(500).json({ message: 'Failed to load verification requests' });
  }
});

app.post('/api/admin/verification/approve', authMiddleware, async (req, res) => {
  try {
    const { requestId, userId, requestType } = req.body;

    if (!requestId || !userId || !requestType) {
      return res.status(400).json({ message: 'requestId, userId, and requestType are required' });
    }

    const updates = {};

    if (requestType === 'seller') {
      updates.is_seller_verified = true;
    } else if (requestType === 'trusted_member') {
      updates.is_trusted_member = true;
    } else {
      return res.status(400).json({ message: 'Invalid request type' });
    }

    const { error: profileError } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', userId);

    if (profileError) throw profileError;

    const { error: requestError } = await supabase
      .from('verification_requests')
      .update({ status: 'approved', reviewed_by: req.admin.username })
      .eq('id', requestId);

    if (requestError) throw requestError;

    res.json({ message: 'Verification request approved' });
  } catch (error) {
    console.error('Approve verification error:', error);
    res.status(500).json({ message: 'Failed to approve verification request' });
  }
});

app.post('/api/admin/verification/reject', authMiddleware, async (req, res) => {
  try {
    const { requestId, reason } = req.body;

    if (!requestId) {
      return res.status(400).json({ message: 'requestId is required' });
    }

    const { error } = await supabase
      .from('verification_requests')
      .update({ status: 'rejected', admin_note: reason || null, reviewed_by: req.admin.username })
      .eq('id', requestId);

    if (error) throw error;

    res.json({ message: 'Verification request rejected' });
  } catch (error) {
    console.error('Reject verification error:', error);
    res.status(500).json({ message: 'Failed to reject verification request' });
  }
});

app.get('/api/admin/properties/pending', authMiddleware, async (req, res) => {
  try {
    let query = supabase
      .from('properties')
      .select('*')
      .order('created_at', { ascending: false });

    if (req.query.status) {
      query = query.eq('status', req.query.status);
    } else {
      query = query.eq('status', 'pending');
    }

    const { data, error } = await query;
    if (error) throw error;

    res.json(data || []);
  } catch (error) {
    console.error('Properties error:', error);
    res.status(500).json({ message: 'Failed to load properties' });
  }
});

app.post('/api/admin/properties/approve', authMiddleware, async (req, res) => {
  try {
    const { propertyId } = req.body;

    if (!propertyId) {
      return res.status(400).json({ message: 'propertyId is required' });
    }

    const { error } = await supabase
      .from('properties')
      .update({ status: 'approved', is_verified: true })
      .eq('id', propertyId);

    if (error) throw error;

    res.json({ message: 'Property approved' });
  } catch (error) {
    console.error('Approve property error:', error);
    res.status(500).json({ message: 'Failed to approve property' });
  }
});

app.post('/api/admin/properties/reject', authMiddleware, async (req, res) => {
  try {
    const { propertyId, reason } = req.body;

    if (!propertyId) {
      return res.status(400).json({ message: 'propertyId is required' });
    }

    const { error } = await supabase
      .from('properties')
      .update({ status: 'rejected', rejection_reason: reason || null })
      .eq('id', propertyId);

    if (error) throw error;

    res.json({ message: 'Property rejected' });
  } catch (error) {
    console.error('Reject property error:', error);
    res.status(500).json({ message: 'Failed to reject property' });
  }
});

app.get('/api/admin/projects/pending', authMiddleware, async (req, res) => {
  try {
    let query = supabase
      .from('kingdom_projects')
      .select('*')
      .order('created_at', { ascending: false });

    if (req.query.status) {
      query = query.eq('status', req.query.status);
    } else {
      query = query.eq('status', 'pending');
    }

    const { data, error } = await query;
    if (error) throw error;

    res.json(data || []);
  } catch (error) {
    console.error('Projects error:', error);
    res.status(500).json({ message: 'Failed to load projects' });
  }
});

app.post('/api/admin/projects/approve', authMiddleware, async (req, res) => {
  try {
    const { projectId } = req.body;

    if (!projectId) {
      return res.status(400).json({ message: 'projectId is required' });
    }

    const { error } = await supabase
      .from('kingdom_projects')
      .update({ status: 'active' })
      .eq('id', projectId);

    if (error) throw error;

    res.json({ message: 'Project approved' });
  } catch (error) {
    console.error('Approve project error:', error);
    res.status(500).json({ message: 'Failed to approve project' });
  }
});

app.post('/api/admin/projects/reject', authMiddleware, async (req, res) => {
  try {
    const { projectId, reason } = req.body;

    if (!projectId) {
      return res.status(400).json({ message: 'projectId is required' });
    }

    const { error } = await supabase
      .from('kingdom_projects')
      .update({ status: 'rejected', rejection_reason: reason || null })
      .eq('id', projectId);

    if (error) throw error;

    res.json({ message: 'Project rejected' });
  } catch (error) {
    console.error('Reject project error:', error);
    res.status(500).json({ message: 'Failed to reject project' });
  }
});

app.listen(PORT, () => {
  console.log(`Admin dashboard server running on http://localhost:${PORT}`);
});

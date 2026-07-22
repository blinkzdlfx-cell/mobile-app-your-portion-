'use client'

import { useState, useEffect } from 'react'
import { AdminLayout } from '@/lib/admin-layout'
import { api } from '@/lib/api-client'
import { useToast } from '@/lib/toast'

interface VerificationRequest {
  id: string
  user_id: string
  request_type: string
  full_name: string
  phone: string
  reason: string
  status: string
  created_at: string
  id_document_url: string | null
  id_type: string | null
  face_image_url: string | null
  admin_note: string | null
  profiles?: { full_name: string; email: string; phone: string }
}

export default function VerificationPage() {
  const { toast } = useToast()
  const [requests, setRequests] = useState<VerificationRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [typeFilter, setTypeFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [rejectModal, setRejectModal] = useState<{ id: string } | null>(null)
  const [rejectReason, setRejectReason] = useState('')

  async function load() {
    setLoading(true)
    try {
      const params: Record<string, string> = {}
      if (typeFilter) params.requestType = typeFilter
      if (statusFilter) params.status = statusFilter
      const data = await api.getVerificationRequests(params)
      setRequests(data)
    } catch { setRequests([]) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [typeFilter, statusFilter])

  async function handleApprove(req: VerificationRequest) {
    setActionLoading(req.id)
    try {
      await api.approveVerification(req.id, req.user_id, req.request_type)
      toast('Verification approved successfully', 'success')
      await load()
    } catch (err: unknown) {
      toast(err instanceof Error ? err.message : 'Failed to approve', 'error')
    }
    finally { setActionLoading(null) }
  }

  async function handleReject() {
    if (!rejectModal) return
    setActionLoading(rejectModal.id)
    try {
      await api.rejectVerification(rejectModal.id, rejectReason || 'No reason provided')
      toast('Verification rejected', 'info')
      setRejectModal(null)
      setRejectReason('')
      await load()
    } catch (err: unknown) {
      toast(err instanceof Error ? err.message : 'Failed to reject', 'error')
    }
    finally { setActionLoading(null) }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Verification Requests</h1>
            <p className="text-gray-500 mt-1">Review seller and trusted member applications.</p>
          </div>
          <button onClick={load} className="btn-secondary !py-2 !px-4 text-sm self-start">
            Refresh
          </button>
        </div>

        <div className="flex gap-3">
          <select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)} className="input-field !w-auto">
            <option value="">All Types</option>
            <option value="seller">Seller</option>
            <option value="trusted_member">Trusted Member</option>
          </select>
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="input-field !w-auto">
            <option value="">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>

        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="card p-6 animate-pulse">
                <div className="h-5 bg-gray-200 rounded w-48 mb-3" />
                <div className="h-4 bg-gray-200 rounded w-32 mb-2" />
                <div className="h-4 bg-gray-200 rounded w-64" />
              </div>
            ))}
          </div>
        ) : requests.length === 0 ? (
          <div className="card p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">No verification requests</h3>
            <p className="text-gray-500">All requests will appear here for review.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {requests.map((req) => (
              <div key={req.id} className="card p-6">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-start gap-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 ${
                      req.request_type === 'seller' ? 'bg-emerald-100' : 'bg-blue-100'
                    }`}>
                      <svg className={`w-6 h-6 ${req.request_type === 'seller' ? 'text-emerald-700' : 'text-blue-700'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        {req.request_type === 'seller' ? (
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        ) : (
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        )}
                      </svg>
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{req.full_name || req.profiles?.full_name || 'Unknown'}</h3>
                      <p className="text-sm text-gray-500">{req.profiles?.email || req.phone || ''}</p>
                      <div className="flex items-center gap-2 mt-2">
                        <span className={`badge-${req.status} text-xs`}>
                          {req.status.charAt(0).toUpperCase() + req.status.slice(1)}
                        </span>
                        <span className="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">
                          {req.request_type === 'seller' ? 'Seller' : 'Trusted Member'}
                        </span>
                      </div>
                      {req.reason && (
                        <p className="text-sm text-gray-600 mt-2"><span className="font-medium">Reason:</span> {req.reason}</p>
                      )}
                      {req.admin_note && (
                        <p className="text-sm text-gray-600 mt-1"><span className="font-medium">Admin note:</span> {req.admin_note}</p>
                      )}
                      {req.id_document_url && (
                        <a href={req.id_document_url} target="_blank" rel="noopener noreferrer" className="text-sm text-primary font-medium hover:underline mt-2 inline-block">
                          View Document
                        </a>
                      )}
                    </div>
                  </div>
                </div>

                {req.status === 'pending' && (
                  <div className="flex gap-3 mt-4 pt-4 border-t border-gray-100">
                    <button
                      onClick={() => handleApprove(req)}
                      disabled={actionLoading === req.id}
                      className="btn-primary !py-2.5 !px-6 text-sm"
                    >
                      {actionLoading === req.id ? 'Processing...' : 'Approve'}
                    </button>
                    <button
                      onClick={() => setRejectModal({ id: req.id })}
                      disabled={actionLoading === req.id}
                      className="btn-secondary !py-2.5 !px-6 text-sm"
                    >
                      Reject
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {rejectModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setRejectModal(null)}>
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Reject Request</h3>
            <p className="text-sm text-gray-500 mb-4">Provide a reason for rejection.</p>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              className="input-field mb-4"
              rows={3}
              placeholder="Reason for rejection..."
            />
            <div className="flex gap-3 justify-end">
              <button onClick={() => setRejectModal(null)} className="btn-secondary !py-2 !px-4 text-sm">Cancel</button>
              <button onClick={handleReject} disabled={actionLoading === rejectModal.id} className="btn-danger !py-2 !px-4 text-sm">
                {actionLoading === rejectModal.id ? 'Rejecting...' : 'Reject'}
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  )
}

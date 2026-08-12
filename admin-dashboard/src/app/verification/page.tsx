'use client'

import { useState, useEffect } from 'react'
import { AdminLayout } from '@/lib/admin-layout'
import { api } from '@/lib/api-client'
import { useToast } from '@/lib/toast'
import DocumentViewer from '@/components/document-viewer'

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
  terminated_at: string | null
  termination_reason: string | null
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
  const [terminateModal, setTerminateModal] = useState<{ id: string } | null>(null)
  const [terminateReason, setTerminateReason] = useState('')
  const [viewer, setViewer] = useState<VerificationRequest | null>(null)

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

  async function handleTerminate() {
    if (!terminateModal) return
    const req = requests.find((r) => r.id === terminateModal.id)
    if (!req) return
    if (!terminateReason.trim()) {
      toast('A reason is required to terminate verification', 'error')
      return
    }
    setActionLoading(terminateModal.id)
    try {
      await api.terminateVerification(terminateModal.id, req.user_id, req.request_type, terminateReason.trim())
      toast('Verification terminated — seller notified', 'success')
      setTerminateModal(null)
      setTerminateReason('')
      await load()
    } catch (err: unknown) {
      toast(err instanceof Error ? err.message : 'Failed to terminate', 'error')
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
                        {req.terminated_at ? (
                          <span className="badge-rejected text-xs">Terminated</span>
                        ) : (
                          <span className={`badge-${req.status} text-xs`}>
                            {req.status.charAt(0).toUpperCase() + req.status.slice(1)}
                          </span>
                        )}
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
                      {req.termination_reason && (
                        <p className="text-sm text-red-600 mt-1"><span className="font-medium">Termination reason:</span> {req.termination_reason}</p>
                      )}
                      {req.id_document_url && (
                        <button
                          onClick={() => setViewer(req)}
                          className="text-sm text-primary font-medium hover:underline mt-2 inline-block bg-transparent border-none p-0 cursor-pointer"
                        >
                          {req.status === 'approved' ? 'Review Documents' : 'View Documents'}
                        </button>
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

      {viewer && (
        <DocumentViewer
          title={`${viewer.full_name || viewer.profiles?.full_name || 'Applicant'} — ${viewer.request_type === 'seller' ? 'Seller' : 'Trusted Member'} verification`}
          subtitle={`${viewer.profiles?.email || viewer.phone || 'No email provided'} · Submitted ${new Date(viewer.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}`}
          idDocumentUrl={viewer.id_document_url}
          faceImageUrl={viewer.face_image_url}
          status={viewer.status}
          terminated={!!viewer.terminated_at}
          terminationReason={viewer.termination_reason}
          onClose={() => setViewer(null)}
          onApprove={() => {
            const req = viewer
            setViewer(null)
            handleApprove(req)
          }}
          onReject={() => {
            const req = viewer
            setViewer(null)
            setRejectModal({ id: req.id })
          }}
          onTerminate={() => {
            const req = viewer
            setViewer(null)
            setTerminateModal({ id: req.id })
          }}
          actionLoading={actionLoading === viewer.id}
        />
      )}

      {terminateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setTerminateModal(null)}>
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-xl bg-red-100 flex items-center justify-center shrink-0">
                <svg className="w-5 h-5 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Terminate Verification</h3>
                <p className="text-sm text-gray-500">This will revoke the seller&apos;s verified status.</p>
              </div>
            </div>
            <textarea
              value={terminateReason}
              onChange={(e) => setTerminateReason(e.target.value)}
              className="input-field mb-4"
              rows={3}
              placeholder="Reason for termination (sent to the seller)..."
              autoFocus
            />
            <div className="flex gap-3 justify-end">
              <button onClick={() => setTerminateModal(null)} className="btn-secondary !py-2 !px-4 text-sm">Cancel</button>
              <button onClick={handleTerminate} disabled={actionLoading === terminateModal.id} className="btn-danger !py-2 !px-4 text-sm">
                {actionLoading === terminateModal.id ? 'Terminating...' : 'Terminate'}
              </button>
            </div>
          </div>
        </div>
      )}

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

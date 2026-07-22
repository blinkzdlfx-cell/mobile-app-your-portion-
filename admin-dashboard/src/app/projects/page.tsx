'use client'

import { useState, useEffect } from 'react'
import { AdminLayout } from '@/lib/admin-layout'
import { api } from '@/lib/api-client'
import { useToast } from '@/lib/toast'

interface Project {
  id: string
  title: string
  description: string
  goal_amount: number
  raised_amount: number
  category: string
  status: string
  created_at: string
}

export default function ProjectsPage() {
  const { toast } = useToast()
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [rejectModal, setRejectModal] = useState<{ id: string } | null>(null)
  const [rejectReason, setRejectReason] = useState('')

  async function load() {
    setLoading(true)
    try {
      const data = await api.getPendingProjects()
      setProjects(data)
    } catch { setProjects([]) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [])

  async function handleApprove(id: string) {
    setActionLoading(id)
    try { await api.approveProject(id); toast('Project approved', 'success'); await load() }
    catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to approve', 'error') }
    finally { setActionLoading(null) }
  }

  async function handleReject() {
    if (!rejectModal) return
    setActionLoading(rejectModal.id)
    try {
      await api.rejectProject(rejectModal.id, rejectReason || 'No reason provided')
      toast('Project rejected', 'info')
      setRejectModal(null); setRejectReason('')
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to reject', 'error') }
    finally { setActionLoading(null) }
  }

  const progressPercent = (raised: number, goal: number) =>
    goal > 0 ? Math.min((raised / goal) * 100, 100) : 0

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Project Approvals</h1>
            <p className="text-gray-500 mt-1">Review and approve Kingdom projects.</p>
          </div>
          <button onClick={load} className="btn-secondary !py-2 !px-4 text-sm">Refresh</button>
        </div>

        {loading ? (
          <div className="space-y-4">
            {[1, 2].map((i) => (
              <div key={i} className="card p-6 animate-pulse">
                <div className="h-5 bg-gray-200 rounded w-48 mb-3" />
                <div className="h-4 bg-gray-200 rounded w-32" />
              </div>
            ))}
          </div>
        ) : projects.length === 0 ? (
          <div className="card p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">No pending projects</h3>
            <p className="text-gray-500">Kingdom projects waiting for approval will appear here.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {projects.map((proj) => {
              const pct = progressPercent(proj.raised_amount, proj.goal_amount)
              return (
                <div key={proj.id} className="card p-6">
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 bg-amber-100 rounded-xl flex items-center justify-center flex-shrink-0">
                        <svg className="w-6 h-6 text-amber-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                      </div>
                      <div className="flex-1">
                        <h3 className="font-semibold text-gray-900">{proj.title}</h3>
                        {proj.description && (
                          <p className="text-sm text-gray-600 mt-1 line-clamp-2">{proj.description}</p>
                        )}
                        <div className="flex flex-wrap items-center gap-3 mt-2">
                          <span className="text-sm font-medium text-primary">Goal: ${proj.goal_amount?.toLocaleString() ?? 'N/A'}</span>
                          <span className="text-sm text-gray-500">Raised: ${proj.raised_amount?.toLocaleString() ?? '$0'}</span>
                          {proj.category && (
                            <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">{proj.category}</span>
                          )}
                        </div>
                        {proj.goal_amount > 0 && (
                          <div className="mt-3">
                            <div className="flex items-center gap-2">
                              <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
                                <div className="h-full bg-gradient-to-r from-amber-400 to-amber-500 rounded-full transition-all duration-500" style={{ width: `${pct}%` }} />
                              </div>
                              <span className="text-xs font-medium text-gray-500">{pct.toFixed(0)}%</span>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {proj.status === 'pending' && (
                    <div className="flex gap-3 mt-4 pt-4 border-t border-gray-100">
                      <button onClick={() => handleApprove(proj.id)} disabled={actionLoading === proj.id} className="btn-primary !py-2.5 !px-6 text-sm">
                        {actionLoading === proj.id ? 'Processing...' : 'Approve'}
                      </button>
                      <button onClick={() => setRejectModal({ id: proj.id })} disabled={actionLoading === proj.id} className="btn-secondary !py-2.5 !px-6 text-sm">
                        Reject
                      </button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>

      {rejectModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setRejectModal(null)}>
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Reject Project</h3>
            <p className="text-sm text-gray-500 mb-4">Provide a reason for rejection.</p>
            <textarea value={rejectReason} onChange={(e) => setRejectReason(e.target.value)} className="input-field mb-4" rows={3} placeholder="Reason for rejection..." />
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

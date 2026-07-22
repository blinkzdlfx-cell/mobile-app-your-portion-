'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { AdminLayout } from '@/lib/admin-layout'
import { api } from '@/lib/api-client'

interface DashboardStats {
  pendingSellerRequests: number
  pendingTrustedRequests: number
  pendingProperties: number
  pendingProjects: number
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [lastUpdated, setLastUpdated] = useState<string | null>(null)
  const router = useRouter()

  async function load() {
    setLoading(true)
    try {
      const data = await api.getDashboard()
      setStats(data)
      setLastUpdated(new Date().toLocaleTimeString())
    } catch {}
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [])

  const cards = [
    { label: 'Seller Requests', value: stats?.pendingSellerRequests ?? 0, href: '/verification', color: 'from-emerald-500 to-emerald-600' },
    { label: 'Trusted Member Requests', value: stats?.pendingTrustedRequests ?? 0, href: '/verification', color: 'from-blue-500 to-blue-600' },
    { label: 'Property Approvals', value: stats?.pendingProperties ?? 0, href: '/properties', color: 'from-violet-500 to-violet-600' },
    { label: 'Project Approvals', value: stats?.pendingProjects ?? 0, href: '/projects', color: 'from-amber-500 to-amber-600' },
  ]

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview</h1>
            <p className="text-gray-500 mt-1">Manage your marketplace approvals and verifications.</p>
          </div>
          <div className="flex items-center gap-3">
            {lastUpdated && (
              <span className="text-xs text-gray-400">Updated {lastUpdated}</span>
            )}
            <button onClick={load} className="btn-secondary !py-2 !px-4 text-sm">
              Refresh
            </button>
          </div>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="card p-6 animate-pulse">
                <div className="h-4 bg-gray-200 rounded w-24 mb-3" />
                <div className="h-8 bg-gray-200 rounded w-16" />
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {cards.map((card) => (
              <button
                key={card.label}
                onClick={() => router.push(card.href)}
                className="card p-6 text-left hover:shadow-lg transition-all duration-200 hover:-translate-y-0.5"
              >
                <p className="text-sm font-medium text-gray-500 mb-2">{card.label}</p>
                <p className="text-4xl font-bold text-gray-900">{card.value}</p>
                <div className={`mt-4 h-1.5 rounded-full bg-gradient-to-r ${card.color} ${card.value === 0 ? 'opacity-30' : ''}`} />
              </button>
            ))}
          </div>
        )}

        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <button onClick={() => router.push('/verification')} className="flex items-center gap-3 p-4 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div className="w-10 h-10 bg-emerald-100 rounded-lg flex items-center justify-center">
                <svg className="w-5 h-5 text-emerald-700" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
              </div>
              <span className="text-sm font-medium text-gray-700">Review Verifications</span>
            </button>
            <button onClick={() => router.push('/properties')} className="flex items-center gap-3 p-4 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div className="w-10 h-10 bg-violet-100 rounded-lg flex items-center justify-center">
                <svg className="w-5 h-5 text-violet-700" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" /></svg>
              </div>
              <span className="text-sm font-medium text-gray-700">Approve Properties</span>
            </button>
            <button onClick={() => router.push('/projects')} className="flex items-center gap-3 p-4 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <div className="w-10 h-10 bg-amber-100 rounded-lg flex items-center justify-center">
                <svg className="w-5 h-5 text-amber-700" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" /></svg>
              </div>
              <span className="text-sm font-medium text-gray-700">Review Projects</span>
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}

'use client'

import { useRouter, usePathname } from 'next/navigation'
import { useAuth } from './auth-context'
import { type ReactNode, useState, useEffect } from 'react'

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6' },
  { href: '/verification', label: 'Verification', icon: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z' },
  { href: '/properties', label: 'Properties', icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4' },
  { href: '/projects', label: 'Projects', icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4' },
]

export function AdminLayout({ children }: { children: ReactNode }) {
  const { isAuthenticated, logout, loading } = useAuth()
  const router = useRouter()
  const pathname = usePathname()
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [showLogoutModal, setShowLogoutModal] = useState(false)

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.replace('/')
    }
  }, [loading, isAuthenticated, router])

  function handleLogout() {
    logout()
    router.replace('/')
  }

  if (loading || !isAuthenticated) return null

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <button onClick={() => setSidebarOpen(!sidebarOpen)} className="lg:hidden p-2 rounded-lg hover:bg-gray-100">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </button>
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <span className="font-bold text-primary text-lg">Your Portion Admin</span>
            </div>
            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-500 hidden sm:block">Admin</span>
              <button onClick={() => setShowLogoutModal(true)} className="btn-danger !py-2 !px-4 text-sm hidden lg:block">
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      {showLogoutModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setShowLogoutModal(false)}>
          <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-sm text-center" onClick={(e) => e.stopPropagation()}>
            <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-5">
              <svg className="w-8 h-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
              </svg>
            </div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Logout</h3>
            <p className="text-gray-500 mb-8">Are you sure you want to logout?</p>
            <div className="flex gap-3">
              <button onClick={() => setShowLogoutModal(false)} className="btn-secondary flex-1 !py-3">
                Cancel
              </button>
              <button onClick={handleLogout} className="btn-danger flex-1 !py-3">
                Okay
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="flex gap-6">
          <aside className={`${sidebarOpen ? 'block' : 'hidden'} lg:block fixed lg:static inset-0 z-[60] lg:z-auto`}>
            <div className="lg:hidden fixed inset-0 bg-black/30" onClick={() => setSidebarOpen(false)} />
            <div className={`relative w-64 bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-1 lg:min-h-[calc(100vh-8rem)] ${sidebarOpen ? 'animate-slide-in-right' : ''} lg:animate-none`}>
              <div className="flex justify-end mb-2 lg:hidden">
                <button onClick={() => setSidebarOpen(false)} className="p-2 rounded-lg hover:bg-gray-100 transition-colors">
                  <svg className="w-5 h-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              {navItems.map((item) => {
                const isActive = pathname.startsWith(item.href)
                return (
                  <button
                    key={item.href}
                    onClick={() => { router.push(item.href); setSidebarOpen(false) }}
                    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 ${
                      isActive ? 'bg-primary text-white shadow-md' : 'text-gray-600 hover:bg-gray-50'
                    }`}
                  >
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d={item.icon} />
                    </svg>
                    {item.label}
                  </button>
                )
              })}
              <div className="pt-4 border-t border-gray-100 lg:hidden">
                <button
                  onClick={() => { setShowLogoutModal(true) }}
                  className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-red-600 hover:bg-red-50 transition-all duration-200"
                >
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
                  </svg>
                  Logout
                </button>
              </div>
            </div>
          </aside>
          <main className="flex-1 min-w-0 animate-fade-in">
            {children}
          </main>
        </div>
      </div>
    </div>
  )
}

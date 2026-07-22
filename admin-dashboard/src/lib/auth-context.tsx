'use client'

import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react'
import { api } from './api-client'

interface AdminUser {
  username: string
  role: 'admin'
}

interface AuthContextType {
  user: AdminUser | null
  token: string | null
  loading: boolean
  login: (username: string, password: string) => Promise<void>
  logout: () => void
  isAuthenticated: boolean
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  loading: true,
  login: async () => {},
  logout: () => {},
  isAuthenticated: false,
})

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AdminUser | null>(null)
  const [token, setToken] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const storedToken = localStorage.getItem('adminToken')
    const storedUser = localStorage.getItem('adminUser')
    if (storedToken && storedUser) {
      setToken(storedToken)
      setUser(JSON.parse(storedUser))
    }
    setLoading(false)
  }, [])

  const login = useCallback(async (username: string, password: string) => {
    const res = await api.login(username, password)
    localStorage.setItem('adminToken', res.token)
    localStorage.setItem('adminUser', JSON.stringify(res.user))
    setToken(res.token)
    setUser(res.user)
  }, [])

  const logout = useCallback(() => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminUser')
    setToken(null)
    setUser(null)
  }, [])

  return (
    <AuthContext.Provider value={{ user, token, loading, login, logout, isAuthenticated: !!token }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)

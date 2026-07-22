import { NextRequest, NextResponse } from 'next/server'
import { createToken, getEnvConfig } from '@/lib/auth'

export const runtime = 'edge'

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json()
    if (!username || !password) {
      return NextResponse.json({ message: 'Username and password are required' }, { status: 400 })
    }

    const config = getEnvConfig()
    if (username !== config.username || password !== config.passwordHash) {
      return NextResponse.json({ message: 'Invalid credentials' }, { status: 401 })
    }

    const token = await createToken({ username, role: 'admin' })
    return NextResponse.json({ token, user: { username, role: 'admin' } })
  } catch {
    return NextResponse.json({ message: 'Login failed' }, { status: 500 })
  }
}

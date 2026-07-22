import { NextResponse } from 'next/server'
import { verifyToken } from './auth'

export function unauthorized() {
  return NextResponse.json({ message: 'Unauthorized' }, { status: 401 })
}

export function serverError(error: unknown, message = 'Internal server error') {
  console.error(message, error)
  return NextResponse.json({ message }, { status: 500 })
}

export function badRequest(message: string) {
  return NextResponse.json({ message }, { status: 400 })
}

export async function authGuard(request: Request) {
  const authHeader = request.headers.get('authorization')
  if (!authHeader?.startsWith('Bearer ')) return null
  const token = authHeader.slice(7)
  return verifyToken(token)
}

export async function handleOptions(request: Request) {
  if (request.method === 'OPTIONS') {
    return new NextResponse(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    })
  }
  return null
}

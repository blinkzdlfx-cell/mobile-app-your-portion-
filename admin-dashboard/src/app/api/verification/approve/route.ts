import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { requestId, userId, requestType } = await request.json()
    if (!requestId || !userId || !requestType) {
      return badRequest('requestId, userId, and requestType are required')
    }

    const sb = getSupabase()
    const updates: Record<string, boolean> = {}

    if (requestType === 'seller') {
      updates.is_seller_verified = true
    } else if (requestType === 'trusted_member') {
      updates.is_trusted_member = true
    } else {
      return badRequest('Invalid request type')
    }

    const { error: profileError } = await sb.from('profiles').update(updates).eq('id', userId)
    if (profileError) throw profileError

    const { error: requestError } = await sb.from('verification_requests').update({ status: 'approved' }).eq('id', requestId)
    if (requestError) throw requestError

    return NextResponse.json({ message: 'Verification request approved' })
  } catch (error) {
    return serverError(error, 'Failed to approve verification request')
  }
}

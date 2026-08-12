import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'
import { notifyUser } from '@/lib/notifications'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { requestId, userId, requestType, reason } = await request.json()
    if (!requestId || !userId || !requestType) {
      return badRequest('requestId, userId, and requestType are required')
    }
    if (!reason?.trim()) {
      return badRequest('A reason is required to terminate verification')
    }

    const sb = getSupabase()
    const updates: Record<string, boolean> = {}

    if (requestType === 'seller') {
      updates.is_seller_verified = false
    } else if (requestType === 'trusted_member') {
      updates.is_trusted_member = false
    } else {
      return badRequest('Invalid request type')
    }

    const { error: profileError } = await sb.from('profiles').update(updates).eq('id', userId)
    if (profileError) throw profileError

    const { error: requestError } = await sb
      .from('verification_requests')
      .update({
        status: 'approved',
        terminated_at: new Date().toISOString(),
        termination_reason: reason,
        admin_note: reason,
      })
      .eq('id', requestId)
    if (requestError) throw requestError

    const label = requestType === 'seller' ? 'Seller' : 'Trusted Member'
    const notifyResult = await notifyUser({
      userId,
      type: 'verification_terminated',
      title: `${label} verification terminated`,
      message: `Your ${label} verification was terminated by an admin. Reason: ${reason}. You can re-apply in the app.`,
      channels: ['in_app', 'push', 'email'],
    })

    return NextResponse.json({ message: 'Verification terminated', notifyResult })
  } catch (error) {
    return serverError(error, 'Failed to terminate verification')
  }
}

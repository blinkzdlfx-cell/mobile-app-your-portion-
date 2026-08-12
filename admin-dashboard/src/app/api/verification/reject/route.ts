import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'
import { notifyUser } from '@/lib/notifications'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { requestId, reason } = await request.json()
    if (!requestId) return badRequest('requestId is required')

    const sb = getSupabase()

    const { data: req, error: fetchError } = await sb
      .from('verification_requests')
      .select('user_id, request_type')
      .eq('id', requestId)
      .maybeSingle()
    if (fetchError) throw fetchError
    if (!req) return badRequest('Verification request not found')

    const { error } = await sb
      .from('verification_requests')
      .update({ status: 'rejected', admin_note: reason || null })
      .eq('id', requestId)
    if (error) throw error

    const label = req.request_type === 'seller' ? 'Seller' : 'Trusted Member'
    const notifyResult = await notifyUser({
      userId: req.user_id,
      type: 'verification_rejected',
      title: `${label} verification rejected`,
      message: `Your ${label} verification request was rejected. Reason: ${reason || 'No reason provided'}. You can re-apply in the app.`,
      channels: ['in_app', 'push', 'email'],
    })

    return NextResponse.json({ message: 'Verification request rejected', notifyResult })
  } catch (error) {
    return serverError(error, 'Failed to reject verification request')
  }
}

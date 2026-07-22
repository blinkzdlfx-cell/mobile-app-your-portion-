import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export const runtime = 'edge'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { requestId, reason } = await request.json()
    if (!requestId) return badRequest('requestId is required')

    const { error } = await getSupabase()
      .from('verification_requests')
      .update({ status: 'rejected', admin_note: reason || null })
      .eq('id', requestId)

    if (error) throw error
    return NextResponse.json({ message: 'Verification request rejected' })
  } catch (error) {
    return serverError(error, 'Failed to reject verification request')
  }
}

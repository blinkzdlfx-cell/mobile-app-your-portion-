import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { propertyId, reason } = await request.json()
    if (!propertyId) return badRequest('propertyId is required')

    const { error } = await getSupabase()
      .from('properties')
      .update({ status: 'rejected', rejection_reason: reason || null })
      .eq('id', propertyId)

    if (error) throw error
    return NextResponse.json({ message: 'Property rejected' })
  } catch (error) {
    return serverError(error, 'Failed to reject property')
  }
}

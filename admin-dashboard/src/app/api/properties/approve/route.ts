import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export const runtime = 'edge'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { propertyId } = await request.json()
    if (!propertyId) return badRequest('propertyId is required')

    const { error } = await getSupabase()
      .from('properties')
      .update({ status: 'approved', is_verified: true })
      .eq('id', propertyId)

    if (error) throw error
    return NextResponse.json({ message: 'Property approved' })
  } catch (error) {
    return serverError(error, 'Failed to approve property')
  }
}

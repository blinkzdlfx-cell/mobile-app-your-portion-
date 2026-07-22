import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { projectId, reason } = await request.json()
    if (!projectId) return badRequest('projectId is required')

    const { error } = await getSupabase()
      .from('kingdom_projects')
      .update({ status: 'rejected', rejection_reason: reason || null })
      .eq('id', projectId)

    if (error) throw error
    return NextResponse.json({ message: 'Project rejected' })
  } catch (error) {
    return serverError(error, 'Failed to reject project')
  }
}

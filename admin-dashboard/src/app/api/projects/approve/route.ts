import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export const runtime = 'edge'

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { projectId } = await request.json()
    if (!projectId) return badRequest('projectId is required')

    const { error } = await getSupabase()
      .from('kingdom_projects')
      .update({ status: 'active' })
      .eq('id', projectId)

    if (error) throw error
    return NextResponse.json({ message: 'Project approved' })
  } catch (error) {
    return serverError(error, 'Failed to approve project')
  }
}

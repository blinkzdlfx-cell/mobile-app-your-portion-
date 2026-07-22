import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError } from '@/lib/api-utils'

export const runtime = 'edge'

export async function GET(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { searchParams } = new URL(request.url)
    let query = getSupabase()
      .from('verification_requests')
      .select('*, profiles!verification_requests_user_id_fkey(full_name, email, phone)')
      .order('created_at', { ascending: false })

    const type = searchParams.get('requestType')
    if (type) query = query.eq('request_type', type)

    const status = searchParams.get('status')
    if (status) query = query.eq('status', status)

    const { data, error } = await query
    if (error) throw error

    return NextResponse.json(data || [])
  } catch (error) {
    return serverError(error, 'Failed to load verification requests')
  }
}

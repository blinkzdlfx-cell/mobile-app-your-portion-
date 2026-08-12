import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError } from '@/lib/api-utils'

const PUBLIC_URL_MARKER = '/object/public/'

function toProxyPath(rawUrl: string | null) {
  if (!rawUrl) return null
  const idx = rawUrl.indexOf(PUBLIC_URL_MARKER)
  if (idx === -1) return rawUrl
  const objectPath = rawUrl.slice(idx + PUBLIC_URL_MARKER.length)
  return `/api/storage/${objectPath}`
}

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

    const rows = (data || []).map((req) => ({
      ...req,
      id_document_url: toProxyPath(req.id_document_url),
      face_image_url: toProxyPath(req.face_image_url),
    }))

    return NextResponse.json(rows)
  } catch (error) {
    return serverError(error, 'Failed to load verification requests')
  }
}

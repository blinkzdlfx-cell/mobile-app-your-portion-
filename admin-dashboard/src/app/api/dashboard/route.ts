import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError } from '@/lib/api-utils'

export const runtime = 'edge'

export async function GET(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const sb = getSupabase()
    const [sellerReq, trustedReq, properties, projects] = await Promise.all([
      sb.from('verification_requests').select('id', { count: 'exact', head: true }).eq('request_type', 'seller').eq('status', 'pending'),
      sb.from('verification_requests').select('id', { count: 'exact', head: true }).eq('request_type', 'trusted_member').eq('status', 'pending'),
      sb.from('properties').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
      sb.from('kingdom_projects').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
    ])

    return NextResponse.json({
      pendingSellerRequests: sellerReq.count ?? 0,
      pendingTrustedRequests: trustedReq.count ?? 0,
      pendingProperties: properties.count ?? 0,
      pendingProjects: projects.count ?? 0,
    })
  } catch (error) {
    return serverError(error, 'Failed to load dashboard stats')
  }
}

import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

export async function GET(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { searchParams } = new URL(request.url)
    const scope = searchParams.get('scope') || 'unposted'

    let query = getSupabase()
      .from('daily_portions')
      .select('id, title, content, scripture_reference, category, is_published, publish_date, created_at')
      .order('created_at', { ascending: false })

    if (scope === 'posted') {
      query = query.eq('is_published', true).not('publish_date', 'is', null)
    } else {
      query = query.eq('is_published', false)
    }

    const { data, error } = await query
    if (error) throw error

    return NextResponse.json(data || [])
  } catch (error) {
    return serverError(error, 'Failed to load daily portions')
  }
}

export async function POST(request: NextRequest) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const body = await request.json()
    const title = (body.title || '').trim()
    const content = (body.content || '').trim()
    if (!title || !content) {
      return badRequest('Title and content are required')
    }

    const { data, error } = await getSupabase()
      .from('daily_portions')
      .insert({
        title,
        content,
        scripture_reference: (body.scripture_reference || '').trim() || null,
        category: (body.category || 'devotional').trim(),
        is_published: false,
        publish_date: null,
      })
      .select('id, title, content, scripture_reference, category, is_published, publish_date, created_at')
      .single()
    if (error) throw error

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    return serverError(error, 'Failed to create daily portion')
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized, serverError, badRequest } from '@/lib/api-utils'

function todayISO() {
  return new Date().toISOString().slice(0, 10)
}

export async function PATCH(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { id } = await params
    const body = await request.json()

    const updates: Record<string, unknown> = {}
    if (typeof body.title === 'string') {
      updates.title = body.title.trim()
    }
    if (typeof body.content === 'string') {
      updates.content = body.content.trim()
    }
    if (typeof body.scripture_reference === 'string') {
      updates.scripture_reference = body.scripture_reference.trim() || null
    }
    if (typeof body.category === 'string') {
      updates.category = body.category.trim()
    }
    if (body.publishNow === true) {
      updates.is_published = true
      updates.publish_date = todayISO()
    } else if (body.unpublish === true) {
      updates.is_published = false
      updates.publish_date = null
    }

    const { data, error } = await getSupabase()
      .from('daily_portions')
      .update(updates)
      .eq('id', id)
      .select('id, title, content, scripture_reference, category, is_published, publish_date, created_at')
      .single()
    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    return serverError(error, 'Failed to update daily portion')
  }
}

export async function DELETE(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  try {
    const { id } = await params

    const { error } = await getSupabase().from('daily_portions').delete().eq('id', id)
    if (error) throw error

    return NextResponse.json({ ok: true })
  } catch (error) {
    return serverError(error, 'Failed to delete daily portion')
  }
}
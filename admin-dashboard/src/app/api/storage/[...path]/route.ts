import { NextRequest, NextResponse } from 'next/server'
import { getSupabase } from '@/lib/supabase'
import { authGuard, unauthorized } from '@/lib/api-utils'

const ALLOWED_BUCKETS = new Set(['verification_documents', 'property_images'])

const MIME_BY_EXT: Record<string, string> = {
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  webp: 'image/webp',
  gif: 'image/gif',
  bmp: 'image/bmp',
  heic: 'image/heic',
  pdf: 'application/pdf',
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path: string[] }> }
) {
  const admin = await authGuard(request)
  if (!admin) return unauthorized()

  const { path } = await params
  const [bucket, ...objectParts] = path

  if (!bucket || objectParts.length === 0) {
    return NextResponse.json({ message: 'Invalid path' }, { status: 400 })
  }
  if (!ALLOWED_BUCKETS.has(bucket)) {
    return NextResponse.json({ message: 'Bucket not allowed' }, { status: 403 })
  }

  const objectPath = objectParts.join('/')
  const ext = objectPath.split('.').pop()?.toLowerCase() ?? ''
  const contentType = MIME_BY_EXT[ext] || 'application/octet-stream'
  const isImage = contentType.startsWith('image/')

  const { data, error } = await getSupabase()
    .storage
    .from(bucket)
    .download(objectPath)

  if (error || !data) {
    return NextResponse.json({ message: 'File not found' }, { status: 404 })
  }

  const bytes = await data.arrayBuffer()

  return new NextResponse(bytes, {
    headers: {
      'Content-Type': contentType,
      'Content-Disposition': `inline; filename="${objectPath.split('/').pop()}"`,
      'Cache-Control': 'private, max-age=3600',
      'X-Content-Type-Options': isImage ? 'nosniff' : '',
    },
  })
}

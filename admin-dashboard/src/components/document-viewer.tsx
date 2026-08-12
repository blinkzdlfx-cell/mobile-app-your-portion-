'use client'

import { useEffect, useState } from 'react'
import { api } from '@/lib/api-client'

interface DocumentViewerProps {
  title: string
  subtitle: string
  idDocumentUrl: string | null
  faceImageUrl: string | null
  status: string
  terminated: boolean
  terminationReason?: string | null
  onClose: () => void
  onApprove?: () => void
  onReject?: () => void
  onTerminate?: () => void
  actionLoading?: boolean
}

interface LoadedDoc {
  objectUrl: string
  fileName: string
  size: number
  isPdf: boolean
}

function isPdf(path: string) {
  return path.split('?')[0].toLowerCase().endsWith('.pdf')
}

function formatSize(bytes: number) {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  if (bytes >= 1024) return `${Math.round(bytes / 1024)} KB`
  return `${bytes} B`
}

function useDocument(path: string | null, retryKey: number) {
  const [doc, setDoc] = useState<LoadedDoc | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!path) return
    let revoked = false
    let objectUrl: string | null = null
    setDoc(null)
    setError('')

    api
      .fetchDocumentBlob(path)
      .then((blob) => {
        objectUrl = URL.createObjectURL(blob)
        if (!revoked) {
          const fileName = decodeURIComponent(path.split('/').pop() || 'document')
          setDoc({
            objectUrl,
            fileName,
            size: blob.size,
            isPdf: isPdf(fileName),
          })
        }
      })
      .catch(() => !revoked && setError('Failed to load document'))

    return () => {
      revoked = true
      if (objectUrl) URL.revokeObjectURL(objectUrl)
    }
  }, [path, retryKey])

  return { doc, error }
}

function PanelHeader({ icon, label, doc }: { icon: string; label: string; doc: LoadedDoc | null }) {
  return (
    <div className="flex items-center gap-3">
      <div className="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
        <svg className="w-4.5 h-4.5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d={icon} />
        </svg>
      </div>
      <div className="min-w-0">
        <h4 className="text-sm font-semibold text-gray-900">{label}</h4>
        {doc && (
          <p className="text-xs text-gray-400 truncate">{doc.fileName} · {formatSize(doc.size)}</p>
        )}
      </div>
    </div>
  )
}

function DocumentPanel({ label, path, icon }: { label: string; path: string | null; icon: string }) {
  const [retryKey, setRetryKey] = useState(0)
  const { doc, error } = useDocument(path, retryKey)
  const [zoom, setZoom] = useState<string | null>(null)

  const showRetry = error && path

  return (
    <div className="flex flex-col min-w-0">
      <PanelHeader icon={icon} label={label} doc={doc} />

      <div className="mt-3 bg-gray-50 border border-gray-100 rounded-xl overflow-hidden flex items-center justify-center min-h-[240px] relative group">
        {!path ? (
          <div className="text-center py-10">
            <svg className="w-8 h-8 text-gray-300 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909M4.5 21h15a2.25 2.25 0 002.25-2.25V5.25A2.25 2.25 0 0019.5 3h-15A2.25 2.25 0 002.25 5.25v13.5A2.25 2.25 0 004.5 21z" />
            </svg>
            <p className="text-sm text-gray-400">Not provided</p>
          </div>
        ) : !doc && !error ? (
          <div className="flex flex-col items-center gap-3 py-10">
            <div className="w-8 h-8 rounded-full border-2 border-primary/30 border-t-primary animate-spin" />
            <p className="text-sm text-gray-400">Loading document…</p>
          </div>
        ) : error ? (
          <div className="text-center py-10 px-6">
            <svg className="w-8 h-8 text-red-400 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
            </svg>
            <p className="text-sm text-red-500 mb-3">{error}</p>
            {showRetry && (
              <button
                onClick={() => setRetryKey((k) => k + 1)}
                className="btn-secondary !py-2 !px-4 text-xs"
              >
                Retry
              </button>
            )}
          </div>
        ) : doc && doc.isPdf ? (
          <iframe
            src={`${doc.objectUrl}#toolbar=1&view=FitH`}
            title={label}
            className="w-full h-[420px] bg-white"
          />
        ) : doc ? (
          <>
            <img
              src={doc.objectUrl}
              alt={label}
              className="max-w-full max-h-[420px] object-contain cursor-zoom-in"
              onClick={() => setZoom(doc.objectUrl)}
            />
            <button
              onClick={() => setZoom(doc.objectUrl)}
              className="absolute bottom-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity bg-gray-900/70 hover:bg-gray-900 text-white text-xs font-medium px-3 py-1.5 rounded-lg flex items-center gap-1.5 backdrop-blur-sm"
            >
              <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607zM10.5 7.5v6m3-3h-6" />
              </svg>
              Zoom
            </button>
          </>
        ) : null}
      </div>

      <div className="flex gap-2 mt-3">
        {doc && (
          <>
            <a
              href={doc.objectUrl}
              download={doc.fileName}
              className="flex-1 inline-flex items-center justify-center gap-1.5 bg-white border border-gray-200 text-gray-700 text-xs font-medium px-3 py-2 rounded-lg hover:bg-gray-50 hover:border-gray-300 transition-all duration-200"
            >
              <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
              </svg>
              Download
            </a>
            <a
              href={doc.objectUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex-1 inline-flex items-center justify-center gap-1.5 bg-white border border-gray-200 text-gray-700 text-xs font-medium px-3 py-2 rounded-lg hover:bg-gray-50 hover:border-gray-300 transition-all duration-200"
            >
              <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
              </svg>
              Open
            </a>
          </>
        )}
      </div>

      {zoom && (
        <div
          className="fixed inset-0 z-[70] bg-black/90 flex items-center justify-center p-6"
          onClick={() => setZoom(null)}
        >
          <img src={zoom} alt={label} className="max-w-full max-h-full object-contain rounded-lg" />
          <button
            onClick={() => setZoom(null)}
            className="absolute top-4 right-4 w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}
    </div>
  )
}

export default function DocumentViewer({
  title,
  subtitle,
  idDocumentUrl,
  faceImageUrl,
  status,
  terminated,
  terminationReason,
  onClose,
  onApprove,
  onReject,
  onTerminate,
  actionLoading,
}: DocumentViewerProps) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', onKey)
    document.body.style.overflow = 'hidden'
    return () => {
      window.removeEventListener('keydown', onKey)
      document.body.style.overflow = ''
    }
  }, [onClose])

  const showDecisionBar =
    (status === 'pending' && !!(onApprove && onReject)) ||
    (status === 'approved' && !terminated && !!onTerminate)

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center p-4 sm:p-6 bg-gray-900/60 backdrop-blur-sm animate-fade-in"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[92vh] flex flex-col animate-scale-in"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4 px-6 pt-6 pb-4 border-b border-gray-100">
          <div className="flex items-start gap-3 min-w-0">
            <div className="w-11 h-11 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
              <svg className="w-5.5 h-5.5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 18.75h-9m9 0a3 3 0 013 3h-15a3 3 0 013-3m9 0v-3.375c0-.621-.503-1.125-1.125-1.125h-.871M7.5 18.75v-3.375c0-.621.504-1.125 1.125-1.125h.872m5.007 0H9.497m5.007 0a7.454 7.454 0 01-.982-3.172M9.497 14.25a7.454 7.454 0 00.981-3.172M5.25 4.236c-.982.143-1.954.317-2.916.52A6.003 6.003 0 007.73 9.728M5.25 4.236V4.5c0 2.108.966 3.99 2.48 5.228M5.25 4.236V2.721C7.456 2.41 9.71 2.25 12 2.25c2.291 0 4.545.16 6.75.47v1.516M7.73 9.728a6.726 6.726 0 002.748 1.35m8.272-6.842V4.5c0 2.108-.966 3.99-2.48 5.228m2.48-5.492a46.32 46.32 0 012.916.52 6.003 6.003 0 01-5.395 4.972m0 0a6.726 6.726 0 01-2.749 1.35m0 0a6.772 6.772 0 01-3.044 0" />
              </svg>
            </div>
            <div className="min-w-0">
              <h3 className="text-lg font-bold text-gray-900 leading-tight">{title}</h3>
              <p className="text-sm text-gray-500 mt-0.5 truncate">{subtitle}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-500 hover:text-gray-700 flex items-center justify-center transition-colors shrink-0"
            aria-label="Close"
          >
            <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-6 py-5 scrollbar-thin">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <DocumentPanel
              label="Government ID"
              path={idDocumentUrl}
              icon="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z"
            />
            <DocumentPanel
              label="Face Image"
              path={faceImageUrl}
              icon="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
            />
          </div>
        </div>

        {showDecisionBar && (
          <div className="px-6 py-4 border-t border-gray-100 flex items-center justify-between gap-4 bg-gray-50 rounded-b-2xl">
            <p className="text-xs text-gray-500 hidden sm:block">
              Reviewed the documents? Decide now.
            </p>
            <div className="flex gap-3 ml-auto">
              {status === 'pending' ? (
                <>
                  <button
                    onClick={onReject}
                    disabled={actionLoading}
                    className="btn-secondary !py-2.5 !px-5 text-sm"
                  >
                    Reject
                  </button>
                  <button
                    onClick={onApprove}
                    disabled={actionLoading}
                    className="btn-primary !py-2.5 !px-5 text-sm"
                  >
                    Approve
                  </button>
                </>
              ) : (
                <button
                  onClick={onTerminate}
                  disabled={actionLoading}
                  className="btn-danger !py-2.5 !px-5 text-sm"
                >
                  Terminate Verification
                </button>
              )}
            </div>
          </div>
        )}

        {status === 'approved' && terminated && (
          <div className="px-6 py-4 border-t border-gray-100 bg-red-50 rounded-b-2xl">
            <div className="flex items-start gap-3">
              <svg className="w-5 h-5 text-red-600 shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
              </svg>
              <div>
                <p className="text-sm font-semibold text-red-700">Verification terminated</p>
                <p className="text-sm text-red-600 mt-0.5">
                  {terminationReason || 'No reason provided'}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

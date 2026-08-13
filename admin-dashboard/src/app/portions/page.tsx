'use client'

import { useState, useEffect } from 'react'
import { AdminLayout } from '@/lib/admin-layout'
import { api } from '@/lib/api-client'
import { useToast } from '@/lib/toast'

interface Portion {
  id: string
  title: string
  content: string
  scripture_reference: string | null
  category: string
  is_published: boolean
  publish_date: string | null
  created_at: string
}

type Tab = 'unposted' | 'posted'

const EMPTY_FORM = { title: '', content: '', scripture_reference: '', category: 'devotional' }

export default function PortionsPage() {
  const { toast } = useToast()
  const [tab, setTab] = useState<Tab>('unposted')
  const [portions, setPortions] = useState<Portion[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [actionId, setActionId] = useState<string | null>(null)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState(EMPTY_FORM)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [deleteId, setDeleteId] = useState<string | null>(null)

  async function load() {
    setLoading(true)
    try {
      const data = await api.getPortions(tab)
      setPortions(data)
    } catch { setPortions([]) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [tab])

  async function handleCreate() {
    if (!form.title.trim() || !form.content.trim()) {
      toast('Title and content are required', 'error')
      return
    }
    setSaving(true)
    try {
      await api.createPortion(form)
      toast('Portion written to the queue', 'success')
      setForm(EMPTY_FORM)
      setShowForm(false)
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to create', 'error') }
    finally { setSaving(false) }
  }

  async function handleSave(portion: Portion) {
    setActionId(portion.id)
    try {
      await api.updatePortion(portion.id, {
        title: portion.title,
        content: portion.content,
        scripture_reference: portion.scripture_reference ?? '',
        category: portion.category,
      })
      toast('Portion saved', 'success')
      setEditingId(null)
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to save', 'error') }
    finally { setActionId(null) }
  }

  async function handlePublish(portion: Portion) {
    setActionId(portion.id)
    try {
      await api.updatePortion(portion.id, { publishNow: true })
      toast('Portion published for today', 'success')
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to publish', 'error') }
    finally { setActionId(null) }
  }

  async function handleUnpublish(portion: Portion) {
    setActionId(portion.id)
    try {
      await api.updatePortion(portion.id, { unpublish: true })
      toast('Portion moved back to unposted', 'info')
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to unpublish', 'error') }
    finally { setActionId(null) }
  }

  async function handleDelete() {
    if (!deleteId) return
    setActionId(deleteId)
    try {
      await api.deletePortion(deleteId)
      toast('Portion deleted', 'info')
      setDeleteId(null)
      await load()
    } catch (err: unknown) { toast(err instanceof Error ? err.message : 'Failed to delete', 'error') }
    finally { setActionId(null) }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Daily Portions</h1>
            <p className="text-gray-500 mt-1">
              Write portions ahead in the queue. The 6am cron posts one per day automatically.
            </p>
          </div>
          <div className="flex gap-2">
            <button onClick={load} className="btn-secondary !py-2 !px-4 text-sm">Refresh</button>
            <button onClick={() => { setShowForm((v) => !v); setEditingId(null) }} className="btn-primary !py-2 !px-4 text-sm">
              {showForm ? 'Close' : '+ New Portion'}
            </button>
          </div>
        </div>

        <div className="flex gap-2 border-b border-gray-200">
          {(['unposted', 'posted'] as Tab[]).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-4 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
                tab === t
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {t === 'unposted' ? 'Unposted (Queue)' : 'Posted'}
            </button>
          ))}
        </div>

        {showForm && (
          <div className="card p-6 space-y-4">
            <h3 className="font-semibold text-gray-900">Write-ahead Portion</h3>
            <input
              className="input-field"
              placeholder="Title *"
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
            />
            <div className="grid grid-cols-2 gap-4">
              <input
                className="input-field"
                placeholder="Scripture reference (e.g. Matthew 13:8)"
                value={form.scripture_reference}
                onChange={(e) => setForm({ ...form, scripture_reference: e.target.value })}
              />
              <input
                className="input-field"
                placeholder="Category (default: devotional)"
                value={form.category}
                onChange={(e) => setForm({ ...form, category: e.target.value })}
              />
            </div>
            <textarea
              className="input-field min-h-[160px]"
              placeholder="Content *"
              value={form.content}
              onChange={(e) => setForm({ ...form, content: e.target.value })}
            />
            <div className="flex justify-end gap-3">
              <button onClick={() => setShowForm(false)} className="btn-secondary !py-2 !px-4 text-sm">Cancel</button>
              <button onClick={handleCreate} disabled={saving} className="btn-primary !py-2 !px-4 text-sm">
                {saving ? 'Saving...' : 'Add to Queue'}
              </button>
            </div>
          </div>
        )}

        {loading ? (
          <div className="space-y-4">
            {[1, 2].map((i) => (
              <div key={i} className="card p-6 animate-pulse">
                <div className="h-5 bg-gray-200 rounded w-48 mb-3" />
                <div className="h-4 bg-gray-200 rounded w-32" />
              </div>
            ))}
          </div>
        ) : portions.length === 0 ? (
          <div className="card p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">
              {tab === 'unposted' ? 'Queue is empty' : 'Nothing posted yet'}
            </h3>
            <p className="text-gray-500">
              {tab === 'unposted'
                ? 'Write portions ahead so the daily cron always has one to post.'
                : 'Posted portions will appear here with their publish dates.'}
            </p>
          </div>
        ) : (
          <div className="space-y-4">
            {portions.map((portion) => (
              <div key={portion.id} className="card p-6">
                {editingId === portion.id ? (
                  <div className="space-y-4">
                    <input
                      className="input-field"
                      value={portion.title}
                      onChange={(e) => setPortions((list) => list.map((p) => p.id === portion.id ? { ...p, title: e.target.value } : p))}
                    />
                    <div className="grid grid-cols-2 gap-4">
                      <input
                        className="input-field"
                        value={portion.scripture_reference ?? ''}
                        onChange={(e) => setPortions((list) => list.map((p) => p.id === portion.id ? { ...p, scripture_reference: e.target.value } : p))}
                      />
                      <input
                        className="input-field"
                        value={portion.category}
                        onChange={(e) => setPortions((list) => list.map((p) => p.id === portion.id ? { ...p, category: e.target.value } : p))}
                      />
                    </div>
                    <textarea
                      className="input-field min-h-[160px]"
                      value={portion.content}
                      onChange={(e) => setPortions((list) => list.map((p) => p.id === portion.id ? { ...p, content: e.target.value } : p))}
                    />
                    <div className="flex gap-3 justify-end">
                      <button onClick={() => setEditingId(null)} className="btn-secondary !py-2 !px-4 text-sm">Cancel</button>
                      <button onClick={() => handleSave(portion)} disabled={actionId === portion.id} className="btn-primary !py-2 !px-4 text-sm">
                        {actionId === portion.id ? 'Saving...' : 'Save'}
                      </button>
                    </div>
                  </div>
                ) : (
                  <>
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 flex-wrap">
                          <h3 className="font-semibold text-gray-900">{portion.title}</h3>
                          {portion.scripture_reference && (
                            <span className="text-xs text-primary bg-primary/10 px-2 py-0.5 rounded-full">
                              {portion.scripture_reference}
                            </span>
                          )}
                          {portion.category && (
                            <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">{portion.category}</span>
                          )}
                        </div>
                        <p className="text-sm text-gray-600 mt-2 line-clamp-3 whitespace-pre-line">{portion.content}</p>
                        <div className="flex flex-wrap items-center gap-3 mt-2 text-xs text-gray-400">
                          {tab === 'posted' && portion.publish_date && (
                            <span>Published: {portion.publish_date}</span>
                          )}
                          {tab === 'unposted' && (
                            <span>In queue since {new Date(portion.created_at).toLocaleDateString()}</span>
                          )}
                        </div>
                      </div>
                    </div>
                    <div className="flex gap-3 mt-4 pt-4 border-t border-gray-100">
                      <button onClick={() => setEditingId(portion.id)} disabled={actionId === portion.id} className="btn-secondary !py-2 !px-4 text-sm">
                        Edit
                      </button>
                      {tab === 'unposted' ? (
                        <button onClick={() => handlePublish(portion)} disabled={actionId === portion.id} className="btn-primary !py-2 !px-4 text-sm">
                          {actionId === portion.id ? 'Publishing...' : 'Publish Now'}
                        </button>
                      ) : (
                        <button onClick={() => handleUnpublish(portion)} disabled={actionId === portion.id} className="btn-secondary !py-2 !px-4 text-sm">
                          Unpost
                        </button>
                      )}
                      <button onClick={() => setDeleteId(portion.id)} disabled={actionId === portion.id} className="btn-danger !py-2 !px-4 text-sm ml-auto">
                        Delete
                      </button>
                    </div>
                  </>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {deleteId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setDeleteId(null)}>
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Delete Portion?</h3>
            <p className="text-sm text-gray-500 mb-4">This cannot be undone.</p>
            <div className="flex gap-3 justify-end">
              <button onClick={() => setDeleteId(null)} className="btn-secondary !py-2 !px-4 text-sm">Cancel</button>
              <button onClick={handleDelete} disabled={actionId === deleteId} className="btn-danger !py-2 !px-4 text-sm">
                {actionId === deleteId ? 'Deleting...' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
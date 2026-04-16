// hooks/useAdminData.ts
'use client'

import { useState, useEffect, useCallback } from 'react'

// Generic fetch hook
function useApiData<T>(endpoint: string, key: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const refetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch(endpoint)
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const json = await res.json()
      setData(json[key] ?? json)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }, [endpoint, key])

  useEffect(() => { refetch() }, [refetch])

  return { data, loading, error, refetch }
}

// ═══════════════════════════════════════════
//  STATS
// ═══════════════════════════════════════════

export function useDashboardStats() {
  const [stats, setStats] = useState<any>(null)
  const [volumeByMonth, setVolumeByMonth] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  const refetch = useCallback(async () => {
    setLoading(true)
    try {
      const res = await fetch('/api/admin/stats')
      const json = await res.json()
      setStats(json.stats)
      setVolumeByMonth(json.volumeByMonth || [])
    } catch (err) {
      console.error('Stats fetch error:', err)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { refetch() }, [refetch])
  return { stats, volumeByMonth, loading, refetch }
}

// ═══════════════════════════════════════════
//  ASSETS
// ═══════════════════════════════════════════

export function useAssets() {
  const { data, loading, error, refetch } = useApiData<any[]>('/api/admin/assets', 'assets')

  const updateStatus = useCallback(async (assetId: string, assetType: string, action: 'approve' | 'reject') => {
    try {
      const res = await fetch('/api/admin/assets', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ assetId, assetType, action }),
      })
      if (!res.ok) throw new Error('Update failed')
      await refetch()
      return true
    } catch (err) {
      console.error('Asset update error:', err)
      return false
    }
  }, [refetch])

  const updateAsset = useCallback(async (assetId: string, assetType: string, updates: Record<string, any>) => {
    try {
      const res = await fetch('/api/admin/assets', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ assetId, assetType, action: 'update', updates }),
      })
      if (!res.ok) throw new Error('Update failed')
      await refetch()
      return true
    } catch (err) {
      console.error('Asset update error:', err)
      return false
    }
  }, [refetch])

  return { assets: data || [], loading, error, refetch, updateStatus, updateAsset }
}

// ═══════════════════════════════════════════
//  USERS
// ═══════════════════════════════════════════

export function useUsers() {
  const { data, loading, error, refetch } = useApiData<any[]>('/api/admin/users', 'users')

  const updateKyc = useCallback(async (userId: string, status: 'approved' | 'rejected') => {
    try {
      const res = await fetch('/api/admin/users', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, action: 'kyc', value: status }),
      })
      if (!res.ok) throw new Error('KYC update failed')
      await refetch()
      return true
    } catch (err) {
      console.error('KYC update error:', err)
      return false
    }
  }, [refetch])

  const updateRole = useCallback(async (userId: string, role: string) => {
    try {
      const res = await fetch('/api/admin/users', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, action: 'role', value: role }),
      })
      if (!res.ok) throw new Error('Role update failed')
      await refetch()
      return true
    } catch (err) {
      console.error('Role update error:', err)
      return false
    }
  }, [refetch])

  return { users: data || [], loading, error, refetch, updateKyc, updateRole }
}

// ═══════════════════════════════════════════
//  TRANSACTIONS
// ═══════════════════════════════════════════

export function useTransactions() {
  const { data, loading, error, refetch } = useApiData<any[]>('/api/admin/transactions', 'transactions')
  return { transactions: data || [], loading, error, refetch }
}

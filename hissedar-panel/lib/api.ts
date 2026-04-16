// lib/api.ts
// 
// Supabase query fonksiyonları — Admin Dashboard
// Service role key ile çalışır, RLS bypass eder.
// Next.js API routes veya Server Components içinden çağrılır.

import { supabaseAdmin } from './supabase-admin'

// ═══════════════════════════════════════════
//  TYPES
// ═══════════════════════════════════════════

export interface DashboardStats {
  totalUsers: number
  activeUsers: number
  totalAssets: number
  pendingAssets: number
  totalVolume: number
  monthlyVolume: number
  pendingKyc: number
  totalRentDistributed: number
}

export interface AssetRow {
  id: string
  title: string
  description: string
  type: 'property' | 'art' | 'nft'
  category: string
  city: string | null
  total_value: number
  token_price: number
  total_tokens: number
  sold_tokens: number
  status: string
  annual_yield: number
  image_url: string | null
  badge: string | null
  created_at: string
  shareholder_count?: number
}

export interface UserRow {
  id: string
  full_name: string
  email: string
  kyc_status: string
  role: string
  created_at: string
  last_active: string | null
  wallet?: {
    balance: number
    hsr_balance: number
    total_invested: number
  }
}

export interface TransactionRow {
  id: string
  user_id: string
  user_name?: string
  type: string
  asset_type: string
  asset_id: string
  asset_title?: string
  token_amount: number
  price_per_token: number
  total_price: number
  amount: number
  status: string
  currency: string
  description: string
  created_at: string
}

// ═══════════════════════════════════════════
//  OVERVIEW / STATS
// ═══════════════════════════════════════════

export async function fetchDashboardStats(): Promise<DashboardStats> {
  // Total users
  const { count: totalUsers } = await supabaseAdmin
    .from('users')
    .select('*', { count: 'exact', head: true })

  // KYC pending
  const { count: pendingKyc } = await supabaseAdmin
    .from('users')
    .select('*', { count: 'exact', head: true })
    .eq('kyc_status', 'pending')

  // Properties
  const { count: propCount } = await supabaseAdmin
    .from('properties')
    .select('*', { count: 'exact', head: true })

  const { count: artCount } = await supabaseAdmin
    .from('arts')
    .select('*', { count: 'exact', head: true })

  const { count: nftCount } = await supabaseAdmin
    .from('nfts')
    .select('*', { count: 'exact', head: true })

  // Pending assets
  const { count: pendingProps } = await supabaseAdmin
    .from('properties')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending')

  const { count: pendingArts } = await supabaseAdmin
    .from('arts')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending')

  const { count: pendingNfts } = await supabaseAdmin
    .from('nfts')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending')

  // Total volume from transactions
  const { data: volumeData } = await supabaseAdmin
    .from('transactions')
    .select('total_price, created_at')
    .in('type', ['buy', 'sell', 'market_buy', 'market_sell'])
    .eq('status', 'confirmed')

  const totalVolume = volumeData?.reduce((sum, tx) => sum + (tx.total_price || 0), 0) || 0

  // Monthly volume (current month)
  const startOfMonth = new Date()
  startOfMonth.setDate(1)
  startOfMonth.setHours(0, 0, 0, 0)

  const monthlyVolume = volumeData?.filter(tx => 
    new Date(tx.created_at) >= startOfMonth
  ).reduce((sum, tx) => sum + (tx.total_price || 0), 0) || 0

  // Rent distributed
  const { data: rentData } = await supabaseAdmin
    .from('rent_distributions')
    .select('total_amount')

  const totalRentDistributed = rentData?.reduce((sum, r) => sum + (r.total_amount || 0), 0) || 0

  return {
    totalUsers: totalUsers || 0,
    activeUsers: Math.round((totalUsers || 0) * 0.72), // approximate
    totalAssets: (propCount || 0) + (artCount || 0) + (nftCount || 0),
    pendingAssets: (pendingProps || 0) + (pendingArts || 0) + (pendingNfts || 0),
    totalVolume,
    monthlyVolume,
    pendingKyc: pendingKyc || 0,
    totalRentDistributed,
  }
}

// Volume by month (last 6 months)
export async function fetchVolumeByMonth() {
  const months: { month: string; value: number }[] = []
  const now = new Date()

  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
    const nextD = new Date(now.getFullYear(), now.getMonth() - i + 1, 1)

    const { data } = await supabaseAdmin
      .from('transactions')
      .select('total_price')
      .in('type', ['buy', 'sell', 'market_buy', 'market_sell'])
      .eq('status', 'confirmed')
      .gte('created_at', d.toISOString())
      .lt('created_at', nextD.toISOString())

    const monthNames = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara']
    months.push({
      month: monthNames[d.getMonth()],
      value: data?.reduce((sum, tx) => sum + (tx.total_price || 0), 0) || 0,
    })
  }

  return months
}

// ═══════════════════════════════════════════
//  ASSETS
// ═══════════════════════════════════════════

export async function fetchAllAssets(): Promise<AssetRow[]> {
  const assets: AssetRow[] = []

  // Properties
  const { data: properties } = await supabaseAdmin
    .from('properties')
    .select('*')
    .order('created_at', { ascending: false })

  properties?.forEach(p => {
    assets.push({
      id: p.id,
      title: p.title,
      description: p.description,
      type: 'property',
      category: p.category || 'konut',
      city: p.city,
      total_value: p.total_value,
      token_price: p.token_price,
      total_tokens: p.total_tokens,
      sold_tokens: p.sold_tokens,
      status: p.status,
      annual_yield: p.annual_yield || 0,
      image_url: p.image_url,
      badge: p.badge,
      created_at: p.created_at,
    })
  })

  // Arts
  const { data: arts } = await supabaseAdmin
    .from('arts')
    .select('*')
    .order('created_at', { ascending: false })

  arts?.forEach(a => {
    assets.push({
      id: a.id,
      title: a.title,
      description: a.description,
      type: 'art',
      category: a.technique || a.category || 'sanat',
      city: null,
      total_value: a.current_value,
      token_price: a.total_tokens > 0 ? a.current_value / a.total_tokens : 0,
      total_tokens: a.total_tokens,
      sold_tokens: a.sold_tokens,
      status: a.status,
      annual_yield: a.annual_yield || 0,
      image_url: a.image_url,
      badge: a.badge,
      created_at: a.created_at,
    })
  })

  // NFTs
  const { data: nfts } = await supabaseAdmin
    .from('nfts')
    .select('*')
    .order('created_at', { ascending: false })

  nfts?.forEach(n => {
    assets.push({
      id: n.id,
      title: n.title,
      description: n.description,
      type: 'nft',
      category: n.collection_name || 'nft',
      city: null,
      total_value: n.current_value,
      token_price: n.total_tokens > 0 ? n.current_value / n.total_tokens : 0,
      total_tokens: n.total_tokens,
      sold_tokens: n.sold_tokens,
      status: n.status,
      annual_yield: 0,
      image_url: n.image_url,
      badge: n.badge,
      created_at: n.created_at,
    })
  })

  return assets.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
}

// Get shareholder count for an asset
export async function fetchShareholderCount(assetId: string, assetType: string): Promise<number> {
  const { count } = await supabaseAdmin
    .from('holdings')
    .select('*', { count: 'exact', head: true })
    .eq('asset_id', assetId)
    .eq('asset_type', assetType)
    .gt('token_amount', 0)

  return count || 0
}

// Update asset status (approve/reject)
export async function updateAssetStatus(
  assetId: string,
  assetType: 'property' | 'art' | 'nft',
  newStatus: 'active' | 'rejected'
) {
  const table = assetType === 'property' ? 'properties' : assetType === 'art' ? 'arts' : 'nfts'

  const { error } = await supabaseAdmin
    .from(table)
    .update({ status: newStatus, updated_at: new Date().toISOString() })
    .eq('id', assetId)

  if (error) throw error
  return { success: true }
}

// Update asset fields
export async function updateAsset(
  assetId: string,
  assetType: 'property' | 'art' | 'nft',
  updates: Record<string, any>
) {
  const table = assetType === 'property' ? 'properties' : assetType === 'art' ? 'arts' : 'nfts'

  const { error } = await supabaseAdmin
    .from(table)
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', assetId)

  if (error) throw error
  return { success: true }
}

// ═══════════════════════════════════════════
//  USERS
// ═══════════════════════════════════════════

export async function fetchAllUsers(): Promise<UserRow[]> {
  const { data: users, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw error

  // Fetch wallets for all users
  const userIds = users?.map(u => u.id) || []

  const { data: wallets } = await supabaseAdmin
    .from('wallets')
    .select('user_id, balance, hsr_balance, total_invested')
    .in('user_id', userIds)

  const walletMap = new Map(wallets?.map(w => [w.user_id, w]))

  return (users || []).map(u => {
    const wallet = walletMap.get(u.id)
    return {
      id: u.id,
      full_name: u.full_name || u.email?.split('@')[0] || 'İsimsiz',
      email: u.email || '',
      kyc_status: u.kyc_status || 'not_started',
      role: u.role || 'user',
      created_at: u.created_at,
      last_active: u.updated_at || u.created_at,
      wallet: wallet ? {
        balance: wallet.balance || 0,
        hsr_balance: wallet.hsr_balance || 0,
        total_invested: wallet.total_invested || 0,
      } : undefined,
    }
  })
}

// Update KYC status
export async function updateKycStatus(userId: string, status: 'approved' | 'rejected') {
  const { error } = await supabaseAdmin
    .from('users')
    .update({ kyc_status: status, updated_at: new Date().toISOString() })
    .eq('id', userId)

  if (error) throw error

  // Send notification
  await supabaseAdmin
    .from('notifications')
    .insert({
      user_id: userId,
      type: status === 'approved' ? 'kyc_approved' : 'kyc_rejected',
      title: status === 'approved' ? 'Kimlik Doğrulandı' : 'Kimlik Doğrulama Reddedildi',
      body: status === 'approved'
        ? 'KYC doğrulamanız onaylandı. Artık yatırım yapabilirsiniz.'
        : 'KYC doğrulamanız reddedildi. Lütfen bilgilerinizi kontrol edip tekrar deneyin.',
      data: {},
    })

  return { success: true }
}

// Ban/unban user
export async function updateUserRole(userId: string, role: 'user' | 'admin' | 'banned') {
  const { error } = await supabaseAdmin
    .from('users')
    .update({ role, updated_at: new Date().toISOString() })
    .eq('id', userId)

  if (error) throw error
  return { success: true }
}

// ═══════════════════════════════════════════
//  TRANSACTIONS
// ═══════════════════════════════════════════

export async function fetchTransactions(limit = 100): Promise<TransactionRow[]> {
  const { data, error } = await supabaseAdmin
    .from('transactions')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw error

  // Fetch user names
  const userIds = Array.from(new Set(data?.map(tx => tx.user_id) || []))
  const { data: users } = await supabaseAdmin
    .from('users')
    .select('id, full_name, email')
    .in('id', userIds)

  const userMap = new Map(users?.map(u => [u.id, u.full_name || u.email?.split('@')[0] || 'İsimsiz']))

  // Fetch asset titles
  const propIds = Array.from(new Set(data?.filter(tx => tx.asset_type === 'property').map(tx => tx.asset_id) || []))
  const artIds = Array.from(new Set(data?.filter(tx => tx.asset_type === 'art').map(tx => tx.asset_id) || []))
  const nftIds = Array.from(new Set(data?.filter(tx => tx.asset_type === 'nft').map(tx => tx.asset_id) || []))

  const titleMap = new Map<string, string>()

  if (propIds.length) {
    const { data: props } = await supabaseAdmin.from('properties').select('id, title').in('id', propIds)
    props?.forEach(p => titleMap.set(p.id, p.title))
  }
  if (artIds.length) {
    const { data: arts } = await supabaseAdmin.from('arts').select('id, title').in('id', artIds)
    arts?.forEach(a => titleMap.set(a.id, a.title))
  }
  if (nftIds.length) {
    const { data: nfts } = await supabaseAdmin.from('nfts').select('id, title').in('id', nftIds)
    nfts?.forEach(n => titleMap.set(n.id, n.title))
  }

  return (data || []).map(tx => ({
    ...tx,
    user_name: userMap.get(tx.user_id) || 'Bilinmiyor',
    asset_title: titleMap.get(tx.asset_id) || tx.description || tx.type,
  }))
}

// ═══════════════════════════════════════════
//  MARKET ORDERS
// ═══════════════════════════════════════════

export async function fetchMarketOrders(status?: string) {
  let query = supabaseAdmin
    .from('market_orders')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(100)

  if (status) query = query.eq('status', status)

  const { data, error } = await query
  if (error) throw error
  return data
}

// ═══════════════════════════════════════════
//  RENT DISTRIBUTIONS
// ═══════════════════════════════════════════

export async function fetchRentDistributions() {
  const { data, error } = await supabaseAdmin
    .from('rent_distributions')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)

  if (error) throw error
  return data
}

// Trigger rent distribution manually
export async function triggerRentDistribution(assetId: string, assetType: string, year: number, month: number) {
  const { data, error } = await supabaseAdmin.rpc('distribute_rent', {
    p_asset_id: assetId,
    p_asset_type: assetType,
    p_year: year,
    p_month: month,
  })

  if (error) throw error
  return data
}

// ═══════════════════════════════════════════
//  BLOCKCHAIN
// ═══════════════════════════════════════════

export async function fetchBlockchainTransactions(status?: string) {
  let query = supabaseAdmin
    .from('blockchain_transactions')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)

  if (status) query = query.eq('status', status)

  const { data, error } = await query
  if (error) throw error
  return data
}
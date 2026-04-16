// app/dashboard/page.tsx
'use client'

import { useState, useEffect, useMemo } from 'react'
import { useDashboardStats, useAssets, useUsers, useTransactions } from '@/hooks/useAdminData'
import { LineChart, Line, AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import {
  Search, Bell, ChevronRight, ChevronLeft, Home, Building2, Users,
  ArrowLeftRight, LogOut, Eye, CheckCircle, XCircle, Clock,
  TrendingUp, Wallet, MoreVertical, Edit, ExternalLink,
  RefreshCw, DollarSign, PieChart as PieIcon, Activity, Shield,
  Layers, UserCheck, UserX, Mail, ArrowUpRight, ArrowDownRight,
  Landmark, Palette, Box
} from 'lucide-react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'

// ═══════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════

const fmt = (n: number) => new Intl.NumberFormat('tr-TR').format(n)
const fmtCurrency = (n: number) => `₺${fmt(n)}`

const statusConfig: Record<string, { label: string; bg: string; text: string; dot: string }> = {
  active: { label: 'Aktif', bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400' },
  pending: { label: 'Beklemede', bg: 'bg-amber-500/10', text: 'text-amber-400', dot: 'bg-amber-400' },
  funded: { label: 'Fonlandı', bg: 'bg-blue-500/10', text: 'text-blue-400', dot: 'bg-blue-400' },
  rejected: { label: 'Reddedildi', bg: 'bg-red-500/10', text: 'text-red-400', dot: 'bg-red-400' },
  approved: { label: 'Onaylı', bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400' },
  confirmed: { label: 'Onaylandı', bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400' },
  completed: { label: 'Tamamlandı', bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400' },
  pending_blockchain: { label: 'Blockchain', bg: 'bg-purple-500/10', text: 'text-purple-400', dot: 'bg-purple-400' },
  open: { label: 'Açık Emir', bg: 'bg-cyan-500/10', text: 'text-cyan-400', dot: 'bg-cyan-400' },
  matched: { label: 'Eşleşti', bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400' },
  not_started: { label: 'Başlanmadı', bg: 'bg-gray-500/10', text: 'text-gray-400', dot: 'bg-gray-400' },
}

const txTypeLabels: Record<string, string> = {
  buy: 'Satın Alma', sell: 'Satış', buy_hsr: 'HSR Alım', sell_hsr: 'HSR Satım',
  dividend: 'Kira Dağıtımı', market_sell: 'Piyasa Satış', market_buy: 'Piyasa Alım',
}

const assetTypeConfig: Record<string, { icon: any; label: string; color: string }> = {
  property: { icon: Building2, label: 'Gayrimenkul', color: '#3B82F6' },
  art: { icon: Palette, label: 'Sanat', color: '#8B5CF6' },
  nft: { icon: Box, label: 'NFT', color: '#F59E0B' },
}

const StatusBadge = ({ status }: { status: string }) => {
  const cfg = statusConfig[status] || { label: status, bg: 'bg-gray-500/10', text: 'text-gray-400', dot: 'bg-gray-400' }
  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${cfg.bg} ${cfg.text}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${cfg.dot}`} />
      {cfg.label}
    </span>
  )
}

// ═══════════════════════════════════════════
//  NAV
// ═══════════════════════════════════════════

const NAV_ITEMS = [
  { id: 'overview', label: 'Genel Bakış', icon: Home },
  { id: 'assets', label: 'Varlık Yönetimi', icon: Building2 },
  { id: 'users', label: 'Kullanıcılar', icon: Users },
  { id: 'transactions', label: 'İşlemler', icon: ArrowLeftRight },
]

// ═══════════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════════

const StatCard = ({ icon: Icon, label, value, sub, color = '#3B82F6' }: any) => (
  <div className="rounded-2xl p-5 border border-white/5 relative overflow-hidden" style={{ background: 'rgba(17,24,39,0.7)' }}>
    <div className="absolute top-0 right-0 w-24 h-24 rounded-full opacity-5" style={{ background: color, filter: 'blur(30px)', transform: 'translate(30%, -30%)' }} />
    <div className="flex items-start justify-between mb-3">
      <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: `${color}15` }}>
        <Icon size={18} style={{ color }} />
      </div>
    </div>
    <p className="text-2xl font-bold text-white tracking-tight">{value}</p>
    <p className="text-xs text-gray-500 mt-1">{label}</p>
    {sub && <p className="text-[11px] text-gray-600 mt-0.5">{sub}</p>}
  </div>
)

// ═══════════════════════════════════════════
//  LOADING SKELETON
// ═══════════════════════════════════════════

const Skeleton = ({ className = '' }: { className?: string }) => (
  <div className={`animate-pulse bg-white/5 rounded-xl ${className}`} />
)

const TableSkeleton = () => (
  <div className="space-y-2 p-4">
    {[...Array(5)].map((_, i) => <Skeleton key={i} className="h-14 w-full" />)}
  </div>
)

// ═══════════════════════════════════════════
//  OVERVIEW PAGE (Real Data)
// ═══════════════════════════════════════════

const OverviewPage = () => {
  const { stats, volumeByMonth, loading, refetch } = useDashboardStats()
  const { transactions, loading: txLoading } = useTransactions()

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => <Skeleton key={i} className="h-32" />)}
        </div>
        <Skeleton className="h-80" />
      </div>
    )
  }

  const d = stats || { totalUsers: 0, activeUsers: 0, totalAssets: 0, totalVolume: 0, monthlyVolume: 0, pendingKyc: 0, pendingAssets: 0, totalRentDistributed: 0 }

  // Asset distribution from real data
  const assetDistribution = [
    { name: 'Gayrimenkul', value: 0, color: '#3B82F6' },
    { name: 'Sanat', value: 0, color: '#8B5CF6' },
    { name: 'NFT', value: 0, color: '#F59E0B' },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div />
        <button onClick={refetch} className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 text-gray-400 hover:text-white text-xs transition-colors">
          <RefreshCw size={12} /> Yenile
        </button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={Users} label="Toplam Kullanıcı" value={fmt(d.totalUsers)} sub={`~${fmt(d.activeUsers)} aktif`} color="#3B82F6" />
        <StatCard icon={Building2} label="Toplam Varlık" value={d.totalAssets} sub={`${d.pendingAssets} onay bekliyor`} color="#8B5CF6" />
        <StatCard icon={DollarSign} label="Toplam Hacim" value={fmtCurrency(d.totalVolume)} sub={`Bu ay: ${fmtCurrency(d.monthlyVolume)}`} color="#10B981" />
        <StatCard icon={Landmark} label="Dağıtılan Kira" value={fmtCurrency(d.totalRentDistributed)} color="#F59E0B" />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 rounded-2xl p-5 border border-white/5" style={{ background: 'rgba(17,24,39,0.7)' }}>
          <p className="text-sm font-semibold text-white mb-1">İşlem Hacmi</p>
          <p className="text-xs text-gray-500 mb-4">Son 6 ay</p>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={volumeByMonth}>
              <defs>
                <linearGradient id="volGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#3B82F6" stopOpacity={0.3} />
                  <stop offset="100%" stopColor="#3B82F6" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
              <XAxis dataKey="month" tick={{ fill: '#6B7280', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6B7280', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={(v: number) => v > 0 ? `${(v / 1_000_000).toFixed(1)}M` : '0'} />
              <Tooltip contentStyle={{ background: '#1F2937', border: '1px solid rgba(255,255,255,0.1)', borderRadius: 12, fontSize: 12, color: '#fff' }} formatter={(v: number) => [fmtCurrency(v), 'Hacim']} />
              <Area type="monotone" dataKey="value" stroke="#3B82F6" strokeWidth={2.5} fill="url(#volGrad)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Pending Actions */}
        <div className="rounded-2xl p-5 border border-white/5" style={{ background: 'rgba(17,24,39,0.7)' }}>
          <p className="text-sm font-semibold text-white mb-4">Bekleyen İşlemler</p>
          <div className="space-y-3">
            {[
              { icon: Shield, label: 'KYC onayı bekleyen', count: d.pendingKyc, color: '#F59E0B' },
              { icon: Building2, label: 'İlan onayı bekleyen', count: d.pendingAssets, color: '#8B5CF6' },
            ].map((item) => {
              const Icon = item.icon
              return (
                <div key={item.label} className="flex items-center justify-between p-3 rounded-xl bg-white/[0.02] border border-white/5">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-lg flex items-center justify-center" style={{ background: `${item.color}15` }}>
                      <Icon size={16} style={{ color: item.color }} />
                    </div>
                    <span className="text-sm text-gray-300">{item.label}</span>
                  </div>
                  <span className="text-sm font-bold text-white">{item.count}</span>
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="rounded-2xl border border-white/5 overflow-hidden" style={{ background: 'rgba(17,24,39,0.7)' }}>
        <div className="px-5 py-4 border-b border-white/5">
          <p className="text-sm font-semibold text-white">Son İşlemler</p>
        </div>
        {txLoading ? <TableSkeleton /> : (
          <div className="divide-y divide-white/5">
            {transactions.slice(0, 5).map((tx: any) => (
              <div key={tx.id} className="flex items-center justify-between px-5 py-3 hover:bg-white/[0.02] transition-colors">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${tx.type?.includes('buy') ? 'bg-emerald-500/10' : tx.type === 'dividend' ? 'bg-amber-500/10' : 'bg-red-500/10'}`}>
                    {tx.type?.includes('buy') ? <ArrowDownRight size={14} className="text-emerald-400" /> : tx.type === 'dividend' ? <Landmark size={14} className="text-amber-400" /> : <ArrowUpRight size={14} className="text-red-400" />}
                  </div>
                  <div>
                    <p className="text-sm text-white">{tx.user_name || 'Bilinmiyor'}</p>
                    <p className="text-xs text-gray-500">{txTypeLabels[tx.type] || tx.type} • {tx.asset_title || tx.description}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-medium text-white">{fmtCurrency(tx.total_price || tx.amount || 0)}</p>
                  <p className="text-xs text-gray-500">{new Date(tx.created_at).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</p>
                </div>
              </div>
            ))}
            {transactions.length === 0 && (
              <div className="py-8 text-center text-gray-500 text-sm">Henüz işlem yok</div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  ASSETS PAGE (Real Data)
// ═══════════════════════════════════════════

const AssetsPage = () => {
  const { assets, loading, updateStatus, refetch } = useAssets()
  const [filter, setFilter] = useState('all')
  const [typeFilter, setTypeFilter] = useState('all')
  const [search, setSearch] = useState('')
  const [selectedAsset, setSelectedAsset] = useState<any>(null)
  const [actionLoading, setActionLoading] = useState(false)

  const filtered = useMemo(() => {
    let list = assets
    if (filter !== 'all') list = list.filter((a: any) => a.status === filter)
    if (typeFilter !== 'all') list = list.filter((a: any) => a.type === typeFilter)
    if (search) list = list.filter((a: any) => a.title?.toLowerCase().includes(search.toLowerCase()))
    return list
  }, [assets, filter, typeFilter, search])

  const handleAction = async (assetId: string, assetType: string, action: 'approve' | 'reject') => {
    setActionLoading(true)
    await updateStatus(assetId, assetType, action)
    setSelectedAsset(null)
    setActionLoading(false)
  }

  if (loading) return <div className="space-y-4"><Skeleton className="h-10 w-48" /><TableSkeleton /></div>

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-white">Varlık Yönetimi</h2>
          <p className="text-xs text-gray-500">{assets.length} varlık • {assets.filter((a: any) => a.status === 'pending').length} onay bekliyor</p>
        </div>
        <button onClick={refetch} className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 text-gray-400 hover:text-white text-xs transition-colors">
          <RefreshCw size={12} /> Yenile
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-2">
        {[{ key: 'all', label: 'Tümü' }, { key: 'active', label: 'Aktif' }, { key: 'pending', label: 'Beklemede' }, { key: 'rejected', label: 'Reddedildi' }].map((f) => (
          <button key={f.key} onClick={() => setFilter(f.key)} className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${filter === f.key ? 'bg-blue-500/20 text-blue-400' : 'bg-white/5 text-gray-400 hover:bg-white/10'}`}>{f.label}</button>
        ))}
        <div className="w-px h-5 bg-white/10 mx-1" />
        {[{ key: 'all', label: 'Tüm Türler' }, { key: 'property', label: 'Gayrimenkul' }, { key: 'art', label: 'Sanat' }, { key: 'nft', label: 'NFT' }].map((f) => (
          <button key={f.key} onClick={() => setTypeFilter(f.key)} className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${typeFilter === f.key ? 'bg-purple-500/20 text-purple-400' : 'bg-white/5 text-gray-400 hover:bg-white/10'}`}>{f.label}</button>
        ))}
        <div className="flex-1" />
        <div className="relative">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
          <input type="text" placeholder="Varlık ara..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9 pr-3 py-2 rounded-xl bg-white/5 border border-white/5 text-sm text-white placeholder-gray-500 outline-none focus:border-blue-500/30 w-56" />
        </div>
      </div>

      {/* Table */}
      <div className="rounded-2xl border border-white/5 overflow-hidden" style={{ background: 'rgba(17,24,39,0.7)' }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-white/5">
                {['Varlık', 'Tür', 'Değer', 'Satış', 'Getiri', 'Durum', 'İşlem'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {filtered.map((asset: any) => {
                const TypeIcon = assetTypeConfig[asset.type]?.icon || Building2
                const progress = asset.total_tokens > 0 ? (asset.sold_tokens / asset.total_tokens) * 100 : 0
                return (
                  <tr key={asset.id} className="hover:bg-white/[0.02] transition-colors cursor-pointer" onClick={() => setSelectedAsset(asset)}>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: `${assetTypeConfig[asset.type]?.color}15` }}>
                          <TypeIcon size={18} style={{ color: assetTypeConfig[asset.type]?.color }} />
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">{asset.title}</p>
                          <p className="text-xs text-gray-500">{asset.city || asset.category}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-xs font-medium px-2 py-0.5 rounded-md" style={{ background: `${assetTypeConfig[asset.type]?.color}15`, color: assetTypeConfig[asset.type]?.color }}>
                        {assetTypeConfig[asset.type]?.label}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-sm text-white font-medium">{fmtCurrency(asset.total_value)}</p>
                      <p className="text-xs text-gray-500">{fmtCurrency(asset.token_price)}/token</p>
                    </td>
                    <td className="px-4 py-3">
                      <div className="w-24">
                        <div className="flex items-center justify-between text-xs mb-1">
                          <span className="text-gray-400">{fmt(asset.sold_tokens)}/{fmt(asset.total_tokens)}</span>
                          <span className="text-white font-medium">{progress.toFixed(0)}%</span>
                        </div>
                        <div className="h-1.5 rounded-full bg-white/5 overflow-hidden">
                          <div className="h-full rounded-full bg-blue-500" style={{ width: `${progress}%` }} />
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-sm text-white">{asset.annual_yield > 0 ? `%${asset.annual_yield}` : '—'}</td>
                    <td className="px-4 py-3"><StatusBadge status={asset.status} /></td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
                        {asset.status === 'pending' && (
                          <>
                            <button onClick={() => handleAction(asset.id, asset.type, 'approve')} disabled={actionLoading} className="p-1.5 rounded-lg hover:bg-emerald-500/10 transition-colors" title="Onayla">
                              <CheckCircle size={16} className="text-emerald-400" />
                            </button>
                            <button onClick={() => handleAction(asset.id, asset.type, 'reject')} disabled={actionLoading} className="p-1.5 rounded-lg hover:bg-red-500/10 transition-colors" title="Reddet">
                              <XCircle size={16} className="text-red-400" />
                            </button>
                          </>
                        )}
                        <button className="p-1.5 rounded-lg hover:bg-white/5 transition-colors"><Eye size={16} className="text-gray-400" /></button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        {filtered.length === 0 && <div className="py-12 text-center text-gray-500 text-sm">Sonuç bulunamadı</div>}
      </div>

      {/* Detail Modal */}
      {selectedAsset && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={() => setSelectedAsset(null)}>
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
          <div className="relative w-full max-w-lg rounded-2xl border border-white/10 p-6 space-y-5 max-h-[85vh] overflow-y-auto" style={{ background: 'linear-gradient(180deg, #111827, #0F172A)' }} onClick={(e) => e.stopPropagation()}>
            <div className="flex items-start justify-between">
              <p className="text-lg font-bold text-white">{selectedAsset.title}</p>
              <button onClick={() => setSelectedAsset(null)} className="p-1 rounded-lg hover:bg-white/5 text-gray-400"><XCircle size={20} /></button>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { l: 'Tür', v: assetTypeConfig[selectedAsset.type]?.label },
                { l: 'Kategori', v: selectedAsset.category },
                { l: 'Şehir', v: selectedAsset.city || '—' },
                { l: 'Durum', v: null, badge: selectedAsset.status },
                { l: 'Toplam Değer', v: fmtCurrency(selectedAsset.total_value) },
                { l: 'Token Fiyatı', v: fmtCurrency(selectedAsset.token_price) },
                { l: 'Satılan Token', v: `${fmt(selectedAsset.sold_tokens)} / ${fmt(selectedAsset.total_tokens)}` },
                { l: 'Yıllık Getiri', v: selectedAsset.annual_yield > 0 ? `%${selectedAsset.annual_yield}` : '—' },
              ].map((item) => (
                <div key={item.l} className="p-3 rounded-xl bg-white/[0.03] border border-white/5">
                  <p className="text-[11px] text-gray-500 mb-1">{item.l}</p>
                  {item.badge ? <StatusBadge status={item.badge} /> : <p className="text-sm font-medium text-white">{item.v}</p>}
                </div>
              ))}
            </div>
            {selectedAsset.status === 'pending' && (
              <div className="flex gap-2">
                <button onClick={() => handleAction(selectedAsset.id, selectedAsset.type, 'approve')} disabled={actionLoading} className="flex-1 py-2.5 rounded-xl bg-emerald-500/15 text-emerald-400 text-sm font-medium hover:bg-emerald-500/25 transition-colors flex items-center justify-center gap-2 disabled:opacity-50">
                  <CheckCircle size={16} /> {actionLoading ? 'İşleniyor...' : 'Onayla'}
                </button>
                <button onClick={() => handleAction(selectedAsset.id, selectedAsset.type, 'reject')} disabled={actionLoading} className="flex-1 py-2.5 rounded-xl bg-red-500/15 text-red-400 text-sm font-medium hover:bg-red-500/25 transition-colors flex items-center justify-center gap-2 disabled:opacity-50">
                  <XCircle size={16} /> {actionLoading ? 'İşleniyor...' : 'Reddet'}
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

// ═══════════════════════════════════════════
//  USERS PAGE (Real Data)
// ═══════════════════════════════════════════

const UsersPage = () => {
  const { users, loading, updateKyc, refetch } = useUsers()
  const [kycFilter, setKycFilter] = useState('all')
  const [search, setSearch] = useState('')
  const [selectedUser, setSelectedUser] = useState<any>(null)
  const [actionLoading, setActionLoading] = useState(false)

  const filtered = useMemo(() => {
    let list = users
    if (kycFilter !== 'all') list = list.filter((u: any) => u.kyc_status === kycFilter)
    if (search) list = list.filter((u: any) => u.full_name?.toLowerCase().includes(search.toLowerCase()) || u.email?.toLowerCase().includes(search.toLowerCase()))
    return list
  }, [users, kycFilter, search])

  const handleKyc = async (userId: string, status: 'approved' | 'rejected') => {
    setActionLoading(true)
    await updateKyc(userId, status)
    setSelectedUser(null)
    setActionLoading(false)
  }

  if (loading) return <div className="space-y-4"><Skeleton className="h-10 w-48" /><div className="grid grid-cols-4 gap-3">{[...Array(4)].map((_, i) => <Skeleton key={i} className="h-28" />)}</div><TableSkeleton /></div>

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-white">Kullanıcı Yönetimi</h2>
          <p className="text-xs text-gray-500">{users.length} kullanıcı</p>
        </div>
        <button onClick={refetch} className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 text-gray-400 hover:text-white text-xs transition-colors"><RefreshCw size={12} /> Yenile</button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard icon={Users} label="Toplam" value={users.length} color="#3B82F6" />
        <StatCard icon={UserCheck} label="KYC Onaylı" value={users.filter((u: any) => u.kyc_status === 'approved').length} color="#10B981" />
        <StatCard icon={Clock} label="KYC Bekliyor" value={users.filter((u: any) => u.kyc_status === 'pending').length} color="#F59E0B" />
        <StatCard icon={UserX} label="Reddedildi" value={users.filter((u: any) => u.kyc_status === 'rejected').length} color="#EF4444" />
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {[{ key: 'all', label: 'Tümü' }, { key: 'approved', label: 'Onaylı' }, { key: 'pending', label: 'Bekliyor' }, { key: 'rejected', label: 'Reddedildi' }].map((f) => (
          <button key={f.key} onClick={() => setKycFilter(f.key)} className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${kycFilter === f.key ? 'bg-blue-500/20 text-blue-400' : 'bg-white/5 text-gray-400 hover:bg-white/10'}`}>{f.label}</button>
        ))}
        <div className="flex-1" />
        <div className="relative">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
          <input type="text" placeholder="Kullanıcı ara..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9 pr-3 py-2 rounded-xl bg-white/5 border border-white/5 text-sm text-white placeholder-gray-500 outline-none focus:border-blue-500/30 w-56" />
        </div>
      </div>

      <div className="rounded-2xl border border-white/5 overflow-hidden" style={{ background: 'rgba(17,24,39,0.7)' }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-white/5">
                {['Kullanıcı', 'KYC', 'Rol', 'TRY Bakiye', 'HSR Bakiye', 'Yatırım', 'İşlem'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {filtered.map((user: any) => (
                <tr key={user.id} className="hover:bg-white/[0.02] transition-colors cursor-pointer" onClick={() => setSelectedUser(user)}>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white text-xs font-bold">
                        {user.full_name?.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase() || '?'}
                      </div>
                      <div>
                        <p className="text-sm font-medium text-white">{user.full_name}</p>
                        <p className="text-xs text-gray-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3"><StatusBadge status={user.kyc_status} /></td>
                  <td className="px-4 py-3">
                    <span className={`text-xs font-medium px-2 py-0.5 rounded-md ${user.role === 'admin' ? 'bg-red-500/10 text-red-400' : 'bg-white/5 text-gray-400'}`}>
                      {user.role === 'admin' ? 'Admin' : 'Kullanıcı'}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-sm text-white">{fmtCurrency(user.wallet?.balance || 0)}</td>
                  <td className="px-4 py-3 text-sm text-white">{fmt(user.wallet?.hsr_balance || 0)} HSR</td>
                  <td className="px-4 py-3 text-sm text-white">{fmtCurrency(user.wallet?.total_invested || 0)}</td>
                  <td className="px-4 py-3" onClick={(e) => e.stopPropagation()}>
                    {user.kyc_status === 'pending' && (
                      <div className="flex items-center gap-1">
                        <button onClick={() => handleKyc(user.id, 'approved')} disabled={actionLoading} className="p-1.5 rounded-lg hover:bg-emerald-500/10 transition-colors"><CheckCircle size={16} className="text-emerald-400" /></button>
                        <button onClick={() => handleKyc(user.id, 'rejected')} disabled={actionLoading} className="p-1.5 rounded-lg hover:bg-red-500/10 transition-colors"><XCircle size={16} className="text-red-400" /></button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filtered.length === 0 && <div className="py-12 text-center text-gray-500 text-sm">Sonuç bulunamadı</div>}
      </div>

      {/* User Modal */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4" onClick={() => setSelectedUser(null)}>
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
          <div className="relative w-full max-w-lg rounded-2xl border border-white/10 p-6 space-y-5" style={{ background: 'linear-gradient(180deg, #111827, #0F172A)' }} onClick={(e) => e.stopPropagation()}>
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold">
                  {selectedUser.full_name?.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase() || '?'}
                </div>
                <div>
                  <p className="text-lg font-bold text-white">{selectedUser.full_name}</p>
                  <p className="text-xs text-gray-500">{selectedUser.email}</p>
                </div>
              </div>
              <button onClick={() => setSelectedUser(null)} className="p-1 rounded-lg hover:bg-white/5 text-gray-400"><XCircle size={20} /></button>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { l: 'KYC Durumu', badge: selectedUser.kyc_status },
                { l: 'Rol', v: selectedUser.role === 'admin' ? 'Admin' : 'Kullanıcı' },
                { l: 'TRY Bakiye', v: fmtCurrency(selectedUser.wallet?.balance || 0) },
                { l: 'HSR Bakiye', v: `${fmt(selectedUser.wallet?.hsr_balance || 0)} HSR` },
                { l: 'Toplam Yatırım', v: fmtCurrency(selectedUser.wallet?.total_invested || 0) },
                { l: 'Katılım', v: new Date(selectedUser.created_at).toLocaleDateString('tr-TR') },
              ].map((item: any) => (
                <div key={item.l} className="p-3 rounded-xl bg-white/[0.03] border border-white/5">
                  <p className="text-[11px] text-gray-500 mb-1">{item.l}</p>
                  {item.badge ? <StatusBadge status={item.badge} /> : <p className="text-sm font-medium text-white">{item.v}</p>}
                </div>
              ))}
            </div>
            {selectedUser.kyc_status === 'pending' && (
              <div className="flex gap-2">
                <button onClick={() => handleKyc(selectedUser.id, 'approved')} disabled={actionLoading} className="flex-1 py-2.5 rounded-xl bg-emerald-500/15 text-emerald-400 text-sm font-medium hover:bg-emerald-500/25 transition-colors flex items-center justify-center gap-2 disabled:opacity-50">
                  <CheckCircle size={16} /> KYC Onayla
                </button>
                <button onClick={() => handleKyc(selectedUser.id, 'rejected')} disabled={actionLoading} className="flex-1 py-2.5 rounded-xl bg-red-500/15 text-red-400 text-sm font-medium hover:bg-red-500/25 transition-colors flex items-center justify-center gap-2 disabled:opacity-50">
                  <XCircle size={16} /> KYC Reddet
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

// ═══════════════════════════════════════════
//  TRANSACTIONS PAGE (Real Data)
// ═══════════════════════════════════════════

const TransactionsPage = () => {
  const { transactions, loading, refetch } = useTransactions()
  const [typeFilter, setTypeFilter] = useState('all')
  const [search, setSearch] = useState('')

  const filtered = useMemo(() => {
    let list = transactions
    if (typeFilter !== 'all') list = list.filter((t: any) => t.type === typeFilter)
    if (search) list = list.filter((t: any) => t.user_name?.toLowerCase().includes(search.toLowerCase()) || t.asset_title?.toLowerCase().includes(search.toLowerCase()))
    return list
  }, [transactions, typeFilter, search])

  if (loading) return <div className="space-y-4"><Skeleton className="h-10 w-48" /><div className="grid grid-cols-4 gap-3">{[...Array(4)].map((_, i) => <Skeleton key={i} className="h-28" />)}</div><TableSkeleton /></div>

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-white">İşlem İzleme</h2>
          <p className="text-xs text-gray-500">{transactions.length} işlem</p>
        </div>
        <button onClick={refetch} className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 text-gray-400 hover:text-white text-xs transition-colors"><RefreshCw size={12} /> Yenile</button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard icon={ArrowLeftRight} label="Toplam İşlem" value={transactions.length} color="#3B82F6" />
        <StatCard icon={DollarSign} label="Toplam Hacim" value={fmtCurrency(transactions.reduce((s: number, t: any) => s + (t.total_price || t.amount || 0), 0))} color="#10B981" />
        <StatCard icon={Activity} label="Blockchain Bekleyen" value={transactions.filter((t: any) => t.status === 'pending_blockchain').length} color="#8B5CF6" />
        <StatCard icon={Landmark} label="Kira Dağıtımları" value={transactions.filter((t: any) => t.type === 'dividend').length} color="#F59E0B" />
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <div className="flex gap-1 p-1 rounded-xl bg-white/5">
          {[{ key: 'all', label: 'Tümü' }, { key: 'buy', label: 'Alım' }, { key: 'sell', label: 'Satış' }, { key: 'buy_hsr', label: 'HSR Alım' }, { key: 'dividend', label: 'Kira' }].map((f) => (
            <button key={f.key} onClick={() => setTypeFilter(f.key)} className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-colors ${typeFilter === f.key ? 'bg-blue-500/20 text-blue-400' : 'text-gray-500 hover:text-gray-300'}`}>{f.label}</button>
          ))}
        </div>
        <div className="flex-1" />
        <div className="relative">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
          <input type="text" placeholder="İşlem ara..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9 pr-3 py-2 rounded-xl bg-white/5 border border-white/5 text-sm text-white placeholder-gray-500 outline-none focus:border-blue-500/30 w-56" />
        </div>
      </div>

      <div className="rounded-2xl border border-white/5 overflow-hidden" style={{ background: 'rgba(17,24,39,0.7)' }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-white/5">
                {['Tarih', 'Kullanıcı', 'İşlem', 'Varlık', 'Token', 'Tutar', 'Durum'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {filtered.map((tx: any) => (
                <tr key={tx.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="px-4 py-3">
                    <p className="text-sm text-white">{new Date(tx.created_at).toLocaleDateString('tr-TR')}</p>
                    <p className="text-xs text-gray-500">{new Date(tx.created_at).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</p>
                  </td>
                  <td className="px-4 py-3">
                    <p className="text-sm text-white">{tx.user_name}</p>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs font-medium px-2 py-0.5 rounded-md ${tx.type?.includes('buy') ? 'bg-emerald-500/10 text-emerald-400' : tx.type === 'dividend' ? 'bg-amber-500/10 text-amber-400' : 'bg-red-500/10 text-red-400'}`}>
                      {txTypeLabels[tx.type] || tx.type}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <p className="text-sm text-white">{tx.asset_title}</p>
                    <p className="text-xs text-gray-500">{assetTypeConfig[tx.asset_type]?.label || tx.asset_type}</p>
                  </td>
                  <td className="px-4 py-3 text-sm text-white">{tx.token_amount > 0 ? fmt(tx.token_amount) : '—'}</td>
                  <td className="px-4 py-3 text-sm font-medium text-white">{fmtCurrency(tx.total_price || tx.amount || 0)}</td>
                  <td className="px-4 py-3"><StatusBadge status={tx.status} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filtered.length === 0 && <div className="py-12 text-center text-gray-500 text-sm">Sonuç bulunamadı</div>}
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  SIDEBAR
// ═══════════════════════════════════════════

const Sidebar = ({ active, onNavigate, collapsed, onToggle }: any) => {
  const router = useRouter()

  const handleLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
  }

  return (
    <div className={`fixed left-0 top-0 h-full z-30 flex flex-col transition-all duration-300 ${collapsed ? 'w-[72px]' : 'w-[260px]'}`} style={{ background: 'linear-gradient(180deg, #0a0f1e 0%, #111827 100%)', borderRight: '1px solid rgba(255,255,255,0.06)' }}>
      <div className="flex items-center gap-3 px-5 h-16 border-b border-white/5">
        <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: 'linear-gradient(135deg, #3B82F6, #8B5CF6)' }}>
          <Layers size={16} className="text-white" />
        </div>
        {!collapsed && (
          <div className="overflow-hidden">
            <p className="text-sm font-bold text-white tracking-wide">HİSSEDAR</p>
            <p className="text-[10px] text-gray-500 tracking-widest uppercase">Admin Panel</p>
          </div>
        )}
      </div>
      <nav className="flex-1 py-4 px-3 space-y-1">
        {NAV_ITEMS.map((item) => {
          const Icon = item.icon
          const isActive = active === item.id
          return (
            <button key={item.id} onClick={() => onNavigate(item.id)} className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${isActive ? 'bg-blue-500/15 text-blue-400' : 'text-gray-400 hover:text-gray-200 hover:bg-white/5'}`}>
              <Icon size={18} />
              {!collapsed && <span>{item.label}</span>}
            </button>
          )
        })}
      </nav>
      <div className="px-3 pb-4 space-y-1">
        <button onClick={handleLogout} className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-gray-400 hover:text-red-400 hover:bg-red-500/5 transition-colors">
          <LogOut size={18} />
          {!collapsed && <span>Çıkış Yap</span>}
        </button>
        <button onClick={onToggle} className="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-gray-500 hover:text-gray-300 hover:bg-white/5 transition-colors text-xs">
          {collapsed ? <ChevronRight size={16} /> : <><ChevronLeft size={16} /><span>Daralt</span></>}
        </button>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════

export default function DashboardPage() {
  const [activePage, setActivePage] = useState('overview')
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)

  const pageTitle = NAV_ITEMS.find((n) => n.id === activePage)?.label || ''

  return (
    <div className="min-h-screen text-white" style={{ background: 'linear-gradient(135deg, #030712 0%, #0a0f1e 50%, #0d1117 100%)' }}>
      <Sidebar active={activePage} onNavigate={setActivePage} collapsed={sidebarCollapsed} onToggle={() => setSidebarCollapsed(!sidebarCollapsed)} />
      <div className={`transition-all duration-300 ${sidebarCollapsed ? 'ml-[72px]' : 'ml-[260px]'}`}>
        <header className="sticky top-0 z-20 h-16 flex items-center justify-between px-6 border-b border-white/5" style={{ background: 'rgba(3,7,18,0.8)', backdropFilter: 'blur(20px)' }}>
          <div>
            <h1 className="text-base font-bold text-white">{pageTitle}</h1>
            <p className="text-xs text-gray-500">Hissedar Yönetim Paneli</p>
          </div>
          <div className="flex items-center gap-3">
            <button className="relative p-2 rounded-xl hover:bg-white/5 transition-colors">
              <Bell size={18} className="text-gray-400" />
            </button>
          </div>
        </header>
        <main className="p-6">
          {activePage === 'overview' && <OverviewPage />}
          {activePage === 'assets' && <AssetsPage />}
          {activePage === 'users' && <UsersPage />}
          {activePage === 'transactions' && <TransactionsPage />}
        </main>
      </div>
    </div>
  )
}

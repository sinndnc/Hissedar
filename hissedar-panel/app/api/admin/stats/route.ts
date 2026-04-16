// app/api/admin/stats/route.ts
import { NextResponse } from 'next/server'
import { fetchDashboardStats, fetchVolumeByMonth } from '@/lib/api'

export async function GET() {
  try {
    const [stats, volumeByMonth] = await Promise.all([
      fetchDashboardStats(),
      fetchVolumeByMonth(),
    ])
    return NextResponse.json({ stats, volumeByMonth })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

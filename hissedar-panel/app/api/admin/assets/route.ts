// app/api/admin/assets/route.ts
import { NextResponse } from 'next/server'
import { fetchAllAssets, updateAssetStatus, updateAsset } from '@/lib/api'

export async function GET() {
  try {
    const assets = await fetchAllAssets()
    return NextResponse.json({ assets })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function PATCH(request: Request) {
  try {
    const body = await request.json()
    const { assetId, assetType, action, updates } = body

    if (action === 'approve' || action === 'reject') {
      const status = action === 'approve' ? 'active' : 'rejected'
      const result = await updateAssetStatus(assetId, assetType, status)
      return NextResponse.json(result)
    }

    if (action === 'update' && updates) {
      const result = await updateAsset(assetId, assetType, updates)
      return NextResponse.json(result)
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

// app/api/admin/transactions/route.ts
import { NextResponse } from 'next/server'
import { fetchTransactions } from '@/lib/api'

export async function GET() {
  try {
    const transactions = await fetchTransactions(200)
    return NextResponse.json({ transactions })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

// app/api/admin/users/route.ts
import { NextResponse } from 'next/server'
import { fetchAllUsers, updateKycStatus, updateUserRole } from '@/lib/api'

export async function GET() {
  try {
    const users = await fetchAllUsers()
    return NextResponse.json({ users })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function PATCH(request: Request) {
  try {
    const body = await request.json()
    const { userId, action, value } = body

    if (action === 'kyc') {
      const result = await updateKycStatus(userId, value)
      return NextResponse.json(result)
    }

    if (action === 'role') {
      const result = await updateUserRole(userId, value)
      return NextResponse.json(result)
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

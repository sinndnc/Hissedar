// lib/supabase-admin.ts
// Server-only admin client — uses service_role key and bypasses RLS.
// NEVER import this file into a Client Component ('use client').
// Only use it in API routes (app/api/**) or Server Components.

import 'server-only'
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { auth: { persistSession: false, autoRefreshToken: false } }
)
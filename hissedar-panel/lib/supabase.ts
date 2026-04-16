// lib/supabase.ts
// Browser client — safe for Client Components.
// Uses cookies so auth session is shared with middleware/server routes.

import { createBrowserClient } from '@supabase/ssr'

export const supabase = createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
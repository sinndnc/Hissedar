// supabase/functions/distribute-rent/index.ts
//
// Kira dağıtım Edge Function.
// İki modda çalışır:
//   1. Cron:  POST { "action": "distribute_all" }
//   2. Manuel: POST { "action": "distribute_single", "asset_id": "...", "year": 2026, "month": 4 }
//
// Deploy: supabase functions deploy distribute-rent
// Cron:   supabase functions deploy distribute-rent --schedule "0 9 1 * *"
//         (Her ayın 1'i saat 09:00 UTC)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

interface DistributeRequest {
  action: "distribute_all" | "distribute_single";
  asset_id?: string;
  asset_type?: string;
  year?: number;
  month?: number;
}

Deno.serve(async (req: Request) => {
  // ─── CORS ───
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  if (req.method !== "POST") {
    return json({ error: "Method Not Allowed" }, 405);
  }

  // ─── Auth kontrolü ───
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Authorization header gerekli" }, 401);
  }

  // Service role key mi kontrol et (cron ve admin işlemleri için)
  const token = authHeader.replace("Bearer ", "");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  // Eğer service role değilse, kullanıcının admin olup olmadığını kontrol et
  if (token !== serviceRoleKey) {
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return json({ error: "Yetkisiz erişim" }, 401);
    }

    // Admin kontrolü (isteğe bağlı: users tablosuna admin kolonu eklenebilir)
    // Şimdilik service_role_key olmadan çağrılamaz
    return json({ error: "Bu işlem sadece admin yetkisiyle yapılabilir" }, 403);
  }

  // ─── Body parse ───
  let body: DistributeRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Geçersiz JSON body" }, 400);
  }

  const { action, asset_id, asset_type = "property", year, month } = body;

  try {
    if (action === "distribute_all") {
      // ─── Tüm mülkler için dağıtım ───
      const { data, error } = await supabase.rpc("distribute_all_rents", {
        p_period_year: year ?? null,
        p_period_month: month ?? null,
      });

      if (error) throw error;

      console.log(
        `[distribute-rent] Toplu dağıtım tamamlandı:`,
        JSON.stringify(data)
      );

      return json(data);

    } else if (action === "distribute_single") {
      // ─── Tek mülk için dağıtım ───
      if (!asset_id) {
        return json({ error: "asset_id gerekli" }, 400);
      }

      const { data, error } = await supabase.rpc("distribute_rent", {
        p_asset_id: asset_id,
        p_asset_type: asset_type,
        p_period_year: year ?? null,
        p_period_month: month ?? null,
      });

      if (error) throw error;

      console.log(
        `[distribute-rent] Tekil dağıtım tamamlandı: ${asset_id}`,
        JSON.stringify(data)
      );

      return json(data);

    } else {
      return json(
        { error: "Geçersiz action. Desteklenen: distribute_all, distribute_single" },
        400
      );
    }
  } catch (err: any) {
    console.error(`[distribute-rent] Hata:`, err);

    const message = err?.message || String(err);
    const statusCode = message.includes("zaten dağıtılmış") ? 409 : 500;

    return json({ error: message }, statusCode);
  }
});

// ─── Helpers ───

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

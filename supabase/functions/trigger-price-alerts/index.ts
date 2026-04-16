// =====================================================
// supabase/functions/trigger-price-alerts/index.ts
// Hissedar: Fiyat Alarm Sistemi - Edge Function
// =====================================================
//
// Bu Edge Function, check_price_alerts() SQL fonksiyonundan
// pg_net aracılığıyla çağrılır. Payload'u alır, bildirim
// mesajını oluşturur ve kullanıcıya push notification gönderir.
//
// Deploy: supabase functions deploy trigger-price-alerts --no-verify-jwt
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

interface PriceAlertPayload {
  alert_id: string;
  user_id: string;
  property_id: string;
  property_title: string;
  condition_type: "below" | "above" | "percent_change";
  target_price: number | null;
  percent_delta: number | null;
  base_price: number | null;
  old_price: number;
  new_price: number;
  behavior: "one_shot" | "recurring";
}

// TL formatla
function formatTL(amount: number): string {
  return new Intl.NumberFormat("tr-TR", {
    style: "currency",
    currency: "TRY",
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(amount);
}

// Koşul tipine göre kullanıcı dostu başlık ve mesaj oluştur
function buildNotificationContent(p: PriceAlertPayload): {
  title: string;
  body: string;
} {
  const propertyName = p.property_title;
  const newPriceStr = formatTL(p.new_price);

  switch (p.condition_type) {
    case "below": {
      const targetStr = formatTL(p.target_price ?? 0);
      return {
        title: "🔔 Fiyat düştü!",
        body: `${propertyName} token fiyatı ${targetStr} hedefinin altına indi. Şu anki fiyat: ${newPriceStr}`,
      };
    }

    case "above": {
      const targetStr = formatTL(p.target_price ?? 0);
      return {
        title: "🔔 Fiyat yükseldi!",
        body: `${propertyName} token fiyatı ${targetStr} hedefinin üstüne çıktı. Şu anki fiyat: ${newPriceStr}`,
      };
    }

    case "percent_change": {
      const percent = p.percent_delta ?? 0;
      const actualChange = p.base_price
        ? ((p.new_price - p.base_price) / p.base_price) * 100
        : 0;
      const direction = actualChange >= 0 ? "arttı" : "düştü";
      const emoji = actualChange >= 0 ? "📈" : "📉";
      return {
        title: `${emoji} Fiyat değişimi`,
        body: `${propertyName} token fiyatı %${Math.abs(actualChange).toFixed(2)} ${direction}. Şu anki fiyat: ${newPriceStr}`,
      };
    }

    default:
      return {
        title: "Fiyat alarmı",
        body: `${propertyName} token fiyatı değişti: ${newPriceStr}`,
      };
  }
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const payload: PriceAlertPayload = await req.json();

    console.log("Price alert triggered:", {
      alert_id: payload.alert_id,
      user_id: payload.user_id,
      condition: payload.condition_type,
      old_price: payload.old_price,
      new_price: payload.new_price,
    });

    // Zorunlu alanları kontrol et
    if (!payload.user_id || !payload.property_id || !payload.alert_id) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Service role client (RLS bypass)
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceKey);

    // Bildirim içeriğini oluştur
    const { title, body } = buildNotificationContent(payload);

    // 1) notifications tablosuna kayıt at (in-app bildirim listesi için)
    const { data: notification, error: insertError } = await supabase
      .from("notifications")
      .insert({
        user_id: payload.user_id,
        type: "price_alert",
        title: title,
        body: body,
        data: {
          alert_id: payload.alert_id,
          property_id: payload.property_id,
          old_price: payload.old_price,
          new_price: payload.new_price,
          condition_type: payload.condition_type,
        },
        is_read: false,
      })
      .select()
      .single();

    if (insertError) {
      console.error("Notification insert error:", insertError);
      // Insert hatası kritik değil, push bildirimi yine de gönder
    }

    // 2) Push notification gönder (mevcut notify-user Edge Function'ı üzerinden)
    const notifyUserUrl = `${supabaseUrl}/functions/v1/notify-user`;
    const notifyResponse = await fetch(notifyUserUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${serviceKey}`,
      },
      body: JSON.stringify({
        user_id: payload.user_id,
        title: title,
        body: body,
        data: {
          type: "price_alert",
          alert_id: payload.alert_id,
          property_id: payload.property_id,
          notification_id: notification?.id,
        },
      }),
    });

    if (!notifyResponse.ok) {
      const errText = await notifyResponse.text();
      console.error("notify-user call failed:", notifyResponse.status, errText);
      // Push başarısız olsa bile in-app notification var, kritik hata değil
    }

    return new Response(
      JSON.stringify({
        success: true,
        alert_id: payload.alert_id,
        notification_id: notification?.id,
        push_sent: notifyResponse.ok,
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("trigger-price-alerts error:", error);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
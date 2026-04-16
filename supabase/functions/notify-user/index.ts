// supabase/functions/notify-user/index.ts
// Kullanıcıya APNs push bildirimi gönderir.
// Diğer Edge Functions bu fonksiyonu çağırır.
// Deploy: supabase functions deploy notify-user

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

// MARK: - APNs JWT oluştur
// APNs HTTP/2 için her istek bir JWT token gerektirir.
async function createAPNsJWT(): Promise<string> {
  const keyId   = Deno.env.get("APNS_KEY_ID")!;
  const teamId  = Deno.env.get("APNS_TEAM_ID")!;
  const privateKeyPEM = Deno.env.get("APNS_PRIVATE_KEY")!;

  // PEM → CryptoKey
  const pemBody = privateKeyPEM
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"]
  );

  return create(
    { alg: "ES256", kid: keyId },
    { iss: teamId, iat: getNumericDate(0) },
    cryptoKey
  );
}

// MARK: - Tek cihaza bildirim gönder
async function sendToDevice(
  deviceToken: string,
  payload: APNsPayload,
  jwt: string
): Promise<boolean> {
  const bundleId = Deno.env.get("APNS_BUNDLE_ID")!;
  // Production: api.push.apple.com  |  Sandbox: api.sandbox.push.apple.com
  const host = "https://api.push.apple.com";

  const res = await fetch(`${host}/3/device/${deviceToken}`, {
    method: "POST",
    headers: {
      "authorization": `bearer ${jwt}`,
      "apns-topic":    bundleId,
      "apns-push-type": payload.aps.contentAvailable ? "background" : "alert",
      "apns-priority":  payload.aps.contentAvailable ? "5" : "10",
      "content-type":  "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    console.error(`APNs hata (${deviceToken.slice(0, 8)}...): ${JSON.stringify(err)}`);

    // Geçersiz token → deaktive et
    if (err.reason === "BadDeviceToken" || err.reason === "Unregistered") {
      await supabase.from("device_tokens")
        .update({ active: false })
        .eq("token", deviceToken);
    }
    return false;
  }

  return true;
}

// MARK: - Kullanıcının tüm aktif cihazlarına gönder
async function notifyUser(
  userId: string,
  notification: NotificationInput
): Promise<{ sent: number; failed: number }> {
  // Aktif device token'ları al
  const { data: tokens } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", userId)
    .eq("active", true)
    .eq("platform", "ios");

  if (!tokens || tokens.length === 0) {
    console.log(`Kullanıcının aktif cihazı yok: ${userId}`);
    return { sent: 0, failed: 0 };
  }

  // JWT bir kez oluştur, tüm isteklerde kullan
  const jwt = await createAPNsJWT();

  const payload: APNsPayload = {
    aps: {
      alert: {
        title: notification.title,
        body:  notification.body,
      },
      badge: notification.badge,
      sound: "default",
    },
    // Custom data — deep link için
    type:        notification.type,
    property_id: notification.propertyId,
    amount:      notification.amount,
  };

  // Tüm cihazlara paralel gönder
  const results = await Promise.all(
    tokens.map(t => sendToDevice(t.token, payload, jwt))
  );

  const sent   = results.filter(Boolean).length;
  const failed = results.filter(r => !r).length;

  // Bildirim geçmişine kaydet
  await supabase.from("notifications").insert({
    user_id: userId,
    type:    notification.type,
    title:   notification.title,
    body:    notification.body,
    data:    { propertyId: notification.propertyId, amount: notification.amount },
  });

  return { sent, failed };
}

// MARK: - HTTP Handler
Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  let body: { userId: string; notification: NotificationInput };
  try {
    body = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  const { userId, notification } = body;
  if (!userId || !notification) {
    return new Response("userId ve notification gerekli", { status: 400 });
  }

  const result = await notifyUser(userId, notification);

  return new Response(JSON.stringify({ ok: true, ...result }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});

// MARK: - Tipler
interface APNsPayload {
  aps: {
    alert?: { title: string; body: string };
    badge?: number;
    sound?: string;
    contentAvailable?: 1;
  };
  type?: string;
  property_id?: string;
  amount?: number;
}

interface NotificationInput {
  type:        string;
  title:       string;
  body:        string;
  badge?:      number;
  propertyId?: string;
  amount?:     number;
}

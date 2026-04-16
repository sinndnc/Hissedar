// supabase/functions/process-notification-queue/index.ts
// Bekleyen bildirimleri kuyruðu iþler.
// pg_cron ile her dakika tetiklenir.
// Deploy: supabase functions deploy process-notification-queue

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const NOTIFY_URL = `${Deno.env.get("SUPABASE_URL")}/functions/v1/notify-user`;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async () => {
  // Bekleyen, zamaný gelmiþ kayýtlarý al (max 50 ? batch iþleme)
  const { data: items, error } = await supabase
    .from("notification_queue")
    .select("*")
    .eq("status", "pending")
    .lte("scheduled_at", new Date().toISOString())
    .lt("attempts", 3) // max_attempts'e ulaþmamýþ
    .order("scheduled_at", { ascending: true })
    .limit(50);

  if (error) {
    console.error("Kuyruk okuma hatasý:", error.message);
    return new Response(JSON.stringify({ ok: false, error: error.message }), { status: 500 });
  }

  if (!items || items.length === 0) {
    return new Response(JSON.stringify({ ok: true, processed: 0 }), { status: 200 });
  }

  // Kuyruðu "sending" olarak iþaretle (çift iþlemi önler)
  const ids = items.map((i: { id: string }) => i.id);
  await supabase.from("notification_queue")
    .update({ status: "sending", attempts: supabase.rpc("increment", { x: 1 }) })
    .in("id", ids);

  let successCount = 0;
  let failCount = 0;

  // Her kuyruðu sýrayla iþle
  for (const item of items) {
    try {
      const res = await fetch(NOTIFY_URL, {
        method: "POST",
        headers: {
          "Content-Type":  "application/json",
          "Authorization": `Bearer ${SERVICE_KEY}`,
        },
        body: JSON.stringify({
          userId:   item.user_id,
          queueId:  item.id,
          notification: {
            type:      item.type,
            title:     item.title,
            body:      item.body,
            deepLink:  item.data?.deep_link,
            propertyId: item.data?.asset_id,
            amount:    item.data?.amount,
          },
        }),
        signal: AbortSignal.timeout(15000),
      });

      if (res.ok) {
        successCount++;
      } else {
        failCount++;
        // Retry zamaný: 1dk, 5dk, 30dk
        const delays = [60, 300, 1800];
        const delay  = delays[item.attempts] ?? 1800;
        await supabase.from("notification_queue").update({
          status:       item.attempts >= 2 ? "failed" : "pending",
          last_error:   `HTTP ${res.status}`,
          next_retry_at: new Date(Date.now() + delay * 1000).toISOString(),
          attempts:     item.attempts + 1,
        }).eq("id", item.id);
      }
    } catch (e) {
      failCount++;
      const err = e instanceof Error ? e.message : "unknown";
      await supabase.from("notification_queue").update({
        status:    item.attempts >= 2 ? "failed" : "pending",
        last_error: err,
        next_retry_at: new Date(Date.now() + 300_000).toISOString(),
        attempts:  item.attempts + 1,
      }).eq("id", item.id);
    }
  }

  console.log(`Ýþlendi: ${successCount} baþarýlý, ${failCount} baþarýsýz`);
  return new Response(JSON.stringify({
    ok: true,
    processed: items.length,
    success: successCount,
    failed: failCount,
  }), { status: 200 });
});
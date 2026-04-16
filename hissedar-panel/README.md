# Hissedar Admin Dashboard

Hissedar RWA platformunun yönetim paneli. Next.js + Supabase + Tailwind CSS.

## Kurulum

```bash
cd hissedar-admin
npm install
```

## Ortam Değişkenleri

`.env.example` dosyasını `.env.local` olarak kopyala ve Supabase bilgilerini gir:

```bash
cp .env.example .env.local
```

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

**ÖNEMLİ:** `SUPABASE_SERVICE_ROLE_KEY` sadece server-side'da kullanılır (API routes). Bu key RLS'yi bypass eder.

## Admin Kullanıcı Ayarla

Supabase SQL Editor'da kendi hesabını admin yap:

```sql
UPDATE users SET role = 'admin' WHERE id = 'b715121d-25ec-458b-a00d-cbbdeca455a7';
```

`users` tablonuzda `role` kolonu yoksa ekleyin:

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';
UPDATE users SET role = 'admin' WHERE id = 'b715121d-25ec-458b-a00d-cbbdeca455a7';
```

## Çalıştırma

```bash
npm run dev
```

Tarayıcıda: `http://localhost:3001`

## Yapı

```
hissedar-admin/
├── app/
│   ├── api/admin/           # API Routes (server-side, service_role ile)
│   │   ├── stats/route.ts   # Dashboard istatistikleri
│   │   ├── assets/route.ts  # Varlık CRUD + onay/red
│   │   ├── users/route.ts   # Kullanıcı + KYC yönetimi
│   │   └── transactions/route.ts
│   ├── dashboard/page.tsx   # Ana dashboard (tüm modüller)
│   ├── login/page.tsx       # Admin giriş sayfası
│   └── layout.tsx
├── hooks/
│   └── useAdminData.ts      # React hooks (API'yi çağırır)
├── lib/
│   ├── supabase.ts          # Supabase client (admin + anon)
│   └── api.ts               # Supabase query fonksiyonları
├── middleware.ts             # Auth + admin role kontrolü
└── .env.example
```

## Modüller

- **Genel Bakış:** Kullanıcı/varlık/hacim istatistikleri, aylık hacim grafiği, bekleyen işlemler, son işlemler
- **Varlık Yönetimi:** Property/Art/NFT listeleme, filtreleme, onay/red, detay modal
- **Kullanıcılar:** KYC yönetimi, bakiye görüntüleme, onay/red, kullanıcı detay
- **İşlemler:** Tüm işlem türleri, filtreleme, blockchain durumu takibi

## Güvenlik

- Middleware: Her `/api/admin/*` ve `/dashboard/*` isteğinde Supabase Auth + admin role kontrolü
- API Routes: `SUPABASE_SERVICE_ROLE_KEY` ile RLS bypass (sadece server-side)
- Login: Supabase Auth ile giriş, `users.role = 'admin'` kontrolü

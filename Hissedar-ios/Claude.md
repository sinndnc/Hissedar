# Hissedar - iOS App

## Proje Özeti
Tokenizasyon yöntemiyle mülkleri eşit parçalara bölen, 
küçük yatırımcıların gayrimenkule ortak olmasını sağlayan iOS uygulaması.

## Tech Stack
- SwiftUI + Swift 6
- MVVM + Combine
- Supabase (Auth + Storage + DB)
- Factory/Container DI
- Push Notifications (APNs)
- Modular yapı

## Proje Yapısı
Hissedar/
├── Core/           # DI container, extensions, base classes
├── Features/       # Her feature kendi modülü
│   ├── Auth/
│   ├── Properties/
│   ├── Portfolio/
│   └── Notifications/
├── Services/       # Supabase, APNs servisleri
└── DesignSystem/   # Renkler, fontlar, component'lar

## Kod Kuralları
- SwiftUI Native Component yapılarını kullan LazyVStack + ScrollView kullanma 
- Swift 6 strict concurrency — @MainActor kullan
- Güncel @Obvervable yapısını kullan ViewModel yapılarında 
- Supabase işlemleri async/await ile yap, Combine ile değil
- Factory DI pattern'i koru (yeni servisler Container'a ekle)

## Komutlar
- Build: Xcode'da ⌘+B
- Test: ⌘+U
- Supabase local: `supabase start`

## Dikkat Edilecekler
- RLS policy olmadan Supabase tablosuna yazma yapma
- Push notification entitlements Xcode'da aktif olmalı
- Swift 6'da actor isolation hatalarına dikkat et

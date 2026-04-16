// NotificationManager.swift
// Tek sorumluluk: APNs token al → Supabase'e kaydet → deep link yönet → realtime badge.
// Kullanım: AppDelegate veya @main App struct'ında NotificationManager.shared'i başlat.

import SwiftUI
import Observation
import UserNotifications
import Supabase
import Factory
import Realtime

@Observable
@MainActor
final class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    @ObservationIgnored
    @AppStorage("apnsDeviceToken") private var storedToken: String = ""
    
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var pendingDeepLink: DeepLink?
    var unreadCount: Int = 0
    
    private var supabase: SupabaseClient { Container.shared.supabaseClient() }
    
    /// Aktif realtime channel
    @ObservationIgnored
    private var realtimeChannel: RealtimeChannelV2?
    
    /// Realtime dinleme aktif mi
    @ObservationIgnored
    private var isSubscribed = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Realtime Subscribe
    
    /// Auth olduktan sonra çağır — notifications tablosundaki INSERT/UPDATE'leri dinler.
    /// Badge ve unreadCount otomatik güncellenir.
    func subscribeToRealtime(userId: String) async {
        guard !isSubscribed else { return }
        
        let channel = supabase.realtimeV2.channel("notifications:\(userId)")
        
        // Yeni bildirim geldiğinde (INSERT)
        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )
        
        // Bildirim okunduğunda (UPDATE) — başka cihazdan okunursa bu cihaz da güncellenir
        let updates = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )
        
        await channel.subscribe()
        
        self.realtimeChannel = channel
        self.isSubscribed = true
        
        // INSERT dinle
        Task { [weak self] in
            for await _ in insertions {
                guard let self else { return }
                await self.refreshUnreadCount(userId: userId)
            }
        }
        
        // UPDATE dinle
        Task { [weak self] in
            for await _ in updates {
                guard let self else { return }
                await self.refreshUnreadCount(userId: userId)
            }
        }
        
        print("Realtime bildirim dinlemesi başlatıldı")
    }
    
    // MARK: - Realtime Unsubscribe
    
    /// Logout veya background'a geçişte çağır.
    func unsubscribeFromRealtime() async {
        guard let channel = realtimeChannel else { return }
        await supabase.realtimeV2.removeChannel(channel)
        realtimeChannel = nil
        isSubscribed = false
        print("Realtime bildirim dinlemesi durduruldu")
    }
    
    // MARK: - İzin İste
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            
            authorizationStatus = granted ? .authorized : .denied
            
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("Bildirim izni hatası: \(error)")
        }
    }
    
    // MARK: - APNs Token Kaydet
    
    func registerDeviceToken(_ tokenData: Data, userId: String) async {
        let token = tokenData.map { String(format: "%02x", $0) }.joined()
        
        guard token != storedToken else { return }
        storedToken = token
        
        do {
            try await supabase
                .from("device_tokens")
                .upsert([
                    "user_id":      userId,
                    "token":        token,
                    "platform":     "ios",
                    "active":       "true",
                    "push_env":     isProductionAPNs() ? "production" : "sandbox",
                    "last_seen_at": ISO8601DateFormatter().string(from: Date()),
                ], onConflict: "token")
                .execute()
            print("APNs token kaydedildi: \(token.prefix(12))...")
        } catch {
            print("Token kayıt hatası: \(error)")
        }
    }
    
    // MARK: - Token Sil (Logout)
    
    func unregisterDeviceToken(userId: String) async {
        guard !storedToken.isEmpty else { return }
        
        // Realtime'ı da kapat
        await unsubscribeFromRealtime()
        
        do {
            try await supabase
                .from("device_tokens")
                .update(["active": false])
                .eq("token", value: storedToken)
                .eq("user_id", value: userId)
                .execute()
            storedToken = ""
        } catch {
            print("Token silme hatası: \(error)")
        }
    }
    
    // MARK: - Okunmamış Sayısı Güncelle
    
    func refreshUnreadCount(userId: String) async {
        do {
            let response = try await supabase
                .from("notifications")
                .select("id", head: true, count: .exact)
                .eq("user_id", value: userId)
                .eq("read", value: false)
                .execute()
            
            unreadCount = response.count ?? 0
            try await UNUserNotificationCenter
                .current()
                .setBadgeCount(unreadCount)
        } catch {
            print("Okunmamış sayı hatası: \(error)")
        }
    }
    
    // MARK: - Bildirimi Okundu İşaretle
    
    func markAsRead(notificationId: String, userId: String) async {
        do {
            try await supabase
                .from("notifications")
                .update(["read": true])
                .eq("id", value: notificationId)
                .execute()
            
            await refreshUnreadCount(userId: userId)
        } catch {
            print("Okundu işaretleme hatası: \(error)")
        }
    }
    
    // MARK: - Tümünü Okundu İşaretle
    
    func markAllAsRead(userId: String) async {
        do {
            try await supabase
                .from("notifications")
                .update(["read": true])
                .eq("user_id", value: userId)
                .eq("read", value: false)
                .execute()
            
            unreadCount = 0
            try await UNUserNotificationCenter
                .current()
                .setBadgeCount(0)
        } catch {
            print("Tümü okundu hatası: \(error)")
        }
    }
    
    // MARK: - Badge Sıfırla
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    // MARK: - Mevcut İzin Durumu
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Production / Sandbox Tespiti
    
    private func isProductionAPNs() -> Bool {
#if DEBUG
        return false
#else
        return true
#endif
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler handler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handleDeepLink(from: userInfo)
        handler()
    }
    
    private func handleDeepLink(from userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        
        let link: DeepLink? = switch type {
        case "dividend":
                .portfolio
        case "price_alert":
            if let assetId = userInfo["asset_id"] as? String {
                .assetDetail(id: assetId, assetType: userInfo["asset_type"] as? String ?? "property")
            } else { .portfolio }
        case "opportunity":
            if let assetId = userInfo["asset_id"] as? String {
                .assetDetail(id: assetId, assetType: userInfo["asset_type"] as? String ?? "property")
            } else { .discover }
        case "security":
                .security
        default:
            nil
        }
        
        pendingDeepLink = link
    }
}

// MARK: - Deep Link Enum
enum DeepLink: Equatable {
    case profile
    case assetDetail(id: String, assetType: String)
    case portfolio
    case watchlist
    case market
    case discover
    case security
}

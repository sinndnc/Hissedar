//
//  NotificationsViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import Foundation
import Observation
import Supabase
import Factory
import Realtime

@Observable
@MainActor
final class NotificationsViewModel {
    
    var notifications: [AppNotification] = []
    var isLoading    = false
    var errorMessage: String?
    
    private var supabase: SupabaseClient { Container.shared.supabaseClient() }
    
    /// Realtime channel — liste güncellemesi için
    private var realtimeChannel: RealtimeChannelV2?
    private var isSubscribed = false
    
    var unreadCount: Int { notifications.filter { !$0.read }.count }
    
    // MARK: - Bildirimleri Yükle + Realtime Başlat
    
    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            notifications = try await supabase
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
        } catch {
            print("HATA DETAYI: \(error)") // Buraya bir breakpoint koyup hatayı incele
            errorMessage = "Bildirimler yüklenemedi"
        }
        

        // İlk yüklemeden sonra realtime dinlemeyi başlat
        await subscribeToRealtime(userId: userId)
    }
    
    // MARK: - Realtime Subscribe
    
    /// notifications tablosundaki INSERT'leri dinler.
    /// Yeni bildirim gelince listeye anında eklenir.
    private func subscribeToRealtime(userId: String) async {
        guard !isSubscribed else { return }
        
        let channel = supabase.realtimeV2.channel("notif-list:\(userId)")
        
        // Yeni bildirim → listeye ekle
        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )
        
        // Bildirim güncellendi (okundu vs.) → listede güncelle
        let updates = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )
        
        await channel.subscribe()
        
        self.realtimeChannel = channel
        self.isSubscribed = true
        
        // INSERT — yeni bildirimi listenin başına ekle
        Task { [weak self] in
            for await action in insertions {
                guard let self else { return }
                do {
                    let newNotification = try action.decodeRecord(
                        as: AppNotification.self,
                        decoder: AppNotification.decoder
                    )
                    // Duplicate kontrolü
                    guard !self.notifications.contains(where: { $0.id == newNotification.id }) else {
                        continue
                    }
                    self.notifications.insert(newNotification, at: 0)
                } catch {
                    print("Realtime INSERT decode hatası: \(error)")
                }
            }
        }
        
        // UPDATE — okundu durumunu güncelle (başka cihazdan okunmuş olabilir)
        Task { [weak self] in
            for await action in updates {
                guard let self else { return }
                do {
                    let updated = try action.decodeRecord(
                        as: AppNotification.self,
                        decoder: AppNotification.decoder
                    )
                    if let idx = self.notifications.firstIndex(where: { $0.id == updated.id }) {
                        self.notifications[idx] = updated
                    }
                } catch {
                    print("Realtime UPDATE decode hatası: \(error)")
                }
            }
        }
    }
    
    // MARK: - Realtime Unsubscribe
    
    /// View kaybolduğunda çağır (onDisappear veya deinit).
    func unsubscribeFromRealtime() async {
        guard let channel = realtimeChannel else { return }
        await supabase.realtimeV2.removeChannel(channel)
        realtimeChannel = nil
        isSubscribed = false
    }
    
    // MARK: - Tek Bildirimi Okundu İşaretle
    
    func markAsRead(id: String, userId: String) async {
        // Önce lokal güncelle — kullanıcı anında görsün
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            let old = notifications[idx]
            notifications[idx] = AppNotification(
                id: old.id, userId: old.userId, title: old.title,
                body: old.body, type: old.type,
                deeplinkTarget: old.deeplinkTarget, data: old.data,
                read: true, sentAt: old.sentAt, createdAt: old.createdAt
            )
        }
        
        // Sonra DB'ye yaz — realtime UPDATE event'i de gelecek ama lokal zaten güncellendi
        try? await supabase
            .from("notifications")
            .update(["read": true])
            .eq("id", value: id)
            .execute()
        
        await NotificationManager.shared.refreshUnreadCount(userId: userId)
    }
    
    // MARK: - Tümünü Okundu İşaretle
    
    func markAllAsRead(userId: String) async {
        notifications = notifications.map { n in
            guard !n.read else { return n }
            return AppNotification(
                id: n.id, userId: n.userId, title: n.title,
                body: n.body, type: n.type,
                deeplinkTarget: n.deeplinkTarget, data: n.data,
                read: true, sentAt: n.sentAt, createdAt: n.createdAt
            )
        }
        
        try? await supabase
            .from("notifications")
            .update(["read": true])
            .eq("user_id", value: userId)
            .eq("read", value: false)
            .execute()
        
        await NotificationManager.shared.markAllAsRead(userId: userId)
    }
}

//
//  NotificationService.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/16/26.
//

import Foundation
import Supabase

extension SupabaseClient {
    
    // MARK: - Oluştur
    
    /// Yeni fiyat alarmı oluşturur.
    @discardableResult
    func createPriceAlert(_ request: CreatePriceAlertRequest) async throws -> PriceAlert {
        let response: PriceAlert = try await self
            .from("price_alerts")
            .insert(request)
            .select()
            .single()
            .execute()
            .value

        return response
    }

    // MARK: - Listele

    /// Kullanıcının tüm alarmlarını getirir (en yeniden en eskiye).
    func fetchPriceAlerts(userId: String) async throws -> [PriceAlert] {
        let response: [PriceAlert] = try await self
            .from("price_alerts")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    /// Kullanıcının belirli bir mülk için olan alarmlarını getirir.
    /// PropertyDetailView'da "Alarm Kur" butonunun badge/count göstermesi için kullanılır.
    func fetchPriceAlerts(userId: String, propertyId: String) async throws -> [PriceAlert] {
        let response: [PriceAlert] = try await self
            .from("price_alerts")
            .select()
            .eq("user_id", value: userId)
            .eq("property_id", value: propertyId)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    /// Sadece aktif alarmları getirir.
    func fetchActivePriceAlerts(userId: String) async throws -> [PriceAlert] {
        let response: [PriceAlert] = try await self
            .from("price_alerts")
            .select()
            .eq("user_id", value: userId)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Güncelle

    /// Alarmı aktif/pasif yap (örn. kullanıcı listede switch'i değiştirdiğinde).
    func setPriceAlertActive(alertId: String, isActive: Bool) async throws {
        struct UpdatePayload: Encodable {
            let isActive: Bool
            enum CodingKeys: String, CodingKey { case isActive = "is_active" }
        }

        try await self
            .from("price_alerts")
            .update(UpdatePayload(isActive: isActive))
            .eq("id", value: alertId)
            .execute()
    }

    // MARK: - Sil

    /// Alarmı tamamen sil.
    func deletePriceAlert(alertId: String) async throws {
        try await self
            .from("price_alerts")
            .delete()
            .eq("id", value: alertId)
            .execute()
    }
}

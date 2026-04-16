//
//  PriceAlertsService.swift
//  Hissedar
//
//  Fiyat alarmları için Service katmanı.
//  Factory ile DI container'a kaydedilir.
//

import Foundation
import Factory
import Supabase

// MARK: - Protokol

protocol PriceAlertsService {
    func createAlert(_ request: CreateAssetPriceAlertRequest) async throws -> AssetPriceAlert

    func fetchAlerts(userId: String) async throws -> [AssetPriceAlert]

    func fetchAlerts(
        userId: String,
        assetId: String,
        assetType: AssetType
    ) async throws -> [AssetPriceAlert]

    func fetchActiveAlerts(userId: String) async throws -> [AssetPriceAlert]

    func setAlertActive(alertId: String, isActive: Bool) async throws

    func deleteAlert(alertId: String) async throws
}

// MARK: - Supabase Implementation

final class SupabasePriceAlertsService: PriceAlertsService {

    private let supabase = Container.shared.supabaseClient()
    private let tableName = "price_alerts"

    // MARK: - Create

    func createAlert(_ request: CreateAssetPriceAlertRequest) async throws -> AssetPriceAlert {
        let response: AssetPriceAlert = try await supabase
            .from(tableName)
            .insert(request)
            .select()
            .single()
            .execute()
            .value

        return response
    }

    // MARK: - Fetch

    func fetchAlerts(userId: String) async throws -> [AssetPriceAlert] {
        let response: [AssetPriceAlert] = try await supabase
            .from(tableName)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    func fetchAlerts(
        userId: String,
        assetId: String,
        assetType: AssetType
    ) async throws -> [AssetPriceAlert] {
        let response: [AssetPriceAlert] = try await supabase
            .from(tableName)
            .select()
            .eq("user_id", value: userId)
            .eq("asset_id", value: assetId)
            .eq("asset_type", value: assetType.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    func fetchActiveAlerts(userId: String) async throws -> [AssetPriceAlert] {
        let response: [AssetPriceAlert] = try await supabase
            .from(tableName)
            .select()
            .eq("user_id", value: userId)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Update

    func setAlertActive(alertId: String, isActive: Bool) async throws {
        struct UpdatePayload: Encodable {
            let isActive: Bool
            enum CodingKeys: String, CodingKey { case isActive = "is_active" }
        }

        try await supabase
            .from(tableName)
            .update(UpdatePayload(isActive: isActive))
            .eq("id", value: alertId)
            .execute()
    }

    // MARK: - Delete

    func deleteAlert(alertId: String) async throws {
        try await supabase
            .from(tableName)
            .delete()
            .eq("id", value: alertId)
            .execute()
    }
}

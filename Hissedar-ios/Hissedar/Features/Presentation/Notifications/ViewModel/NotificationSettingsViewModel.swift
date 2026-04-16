//
//  NotificationSettingsViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import Foundation
import Observation
import Supabase
import Factory

// MARK: - Preferences Model (DB ile 1:1)

struct NotificationPreferences: Codable {
    var pushEnabled: Bool
    var priceAlertsEnabled: Bool
    var dividendEnabled: Bool
    var opportunityEnabled: Bool
    var securityEnabled: Bool
    var systemEnabled: Bool
    var priceAlertThreshold: Double
    var maxPerDay: Int

    enum CodingKeys: String, CodingKey {
        case pushEnabled         = "push_enabled"
        case priceAlertsEnabled  = "price_alerts_enabled"
        case dividendEnabled     = "dividend_enabled"
        case opportunityEnabled  = "opportunity_enabled"
        case securityEnabled     = "security_enabled"
        case systemEnabled       = "system_enabled"
        case priceAlertThreshold = "price_alert_threshold"
        case maxPerDay           = "max_per_day"
    }

    static var defaults: NotificationPreferences {
        NotificationPreferences(
            pushEnabled: true,
            priceAlertsEnabled: true,
            dividendEnabled: true,
            opportunityEnabled: true,
            securityEnabled: true,
            systemEnabled: true,
            priceAlertThreshold: 5.0,
            maxPerDay: 20
        )
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class NotificationSettingsViewModel {
    
    var prefs: NotificationPreferences = .defaults
    var isLoading = false
    var isSaving  = false
    var saveError: String?

    private var supabase: SupabaseClient { Container.shared.supabaseClient() }

    // MARK: - Yükle
    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result: NotificationPreferences = try await supabase
                .from("notification_preferences")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            prefs = result
        } catch {
            // Satır yoksa default değerler kalır
        }
    }

    // MARK: - Kaydet (her toggle değişiminde çağrılır)
    func save(userId: String) async {
        isSaving = true
        defer { isSaving = false }

        struct PrefsPayload: Encodable {
            let user_id: String
            let push_enabled: Bool
            let price_alerts_enabled: Bool
            let dividend_enabled: Bool
            let opportunity_enabled: Bool
            let security_enabled: Bool
            let system_enabled: Bool
            let price_alert_threshold: Double
            let max_per_day: Int
        }

        let payload = PrefsPayload(
            user_id:                userId,
            push_enabled:           prefs.pushEnabled,
            price_alerts_enabled:   prefs.priceAlertsEnabled,
            dividend_enabled:       prefs.dividendEnabled,
            opportunity_enabled:    prefs.opportunityEnabled,
            security_enabled:       prefs.securityEnabled,
            system_enabled:         prefs.systemEnabled,
            price_alert_threshold:  prefs.priceAlertThreshold,
            max_per_day:            prefs.maxPerDay
        )

        do {
            try await supabase
                .from("notification_preferences")
                .upsert(payload, onConflict: "user_id")
                .execute()
            saveError = nil
        } catch {
            saveError = "Kaydetme hatası"
        }
    }
}

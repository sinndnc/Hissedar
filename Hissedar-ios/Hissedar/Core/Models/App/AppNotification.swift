//
//  AppNotification.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/29/26.
//
//  Not: Swift'teki UserNotifications framework'ü ile çakışmaması için
//  model adı "AppNotification" olarak seçildi.

import Foundation

// MARK: - AppNotification
struct AppNotification: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let body: String
    let type: NotificationType
    let deeplinkTarget: String?
    let data: NotificationData?
    let read: Bool
    let sentAt: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId        = "user_id"
        case title, body, type
        case deeplinkTarget = "deeplink_target"
        case data
        case read
        case sentAt        = "sent_at"
        case createdAt     = "created_at"
    }

    /// Realtime decodeRecord için paylaşılan decoder
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}

// MARK: - NotificationData

struct NotificationData: Codable {
    let assetId: String?
    let assetType: String?
    let amount: Double?
    let deepLink: String?

    enum CodingKeys: String, CodingKey {
        case assetId   = "asset_id"
        case assetType = "asset_type"
        case amount
        case deepLink  = "deep_link"
    }
}

// MARK: - NotificationType

enum NotificationType: String, Codable, CaseIterable {
    case order       = "order"
    case dividend    = "dividend"
    case priceAlert  = "price_alert"
    case opportunity = "opportunity"
    case security    = "security"
    case system      = "system"
    case kyc         = "kyc"
    case kycApproved = "kyc_approved"
    case tokenMinted = "token_minted"
    case tokenMintFailed = "token_mint_failed"
    case unknown
    
    var displayName: String {
        switch self {
        case .order:       return "Sipariş"
        case .dividend:    return "Kira Geliri"
        case .priceAlert:  return "Fiyat Uyarısı"
        case .opportunity: return "Yatırım Fırsatı"
        case .security:    return "Güvenlik"
        case .system:      return "Sistem"
        case .kyc:         return "KYC"
        case .kycApproved: return "KYC Onay"
        case .tokenMinted: return "Token alım"
        case .unknown: return "Bilinmeyen"
        case .tokenMintFailed: return "Satın alım hatası"
        }
    }
}

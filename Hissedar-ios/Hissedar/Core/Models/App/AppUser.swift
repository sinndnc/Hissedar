//
//  AppUser.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
    var fullName: String?
    var phone: String?
    var walletAddress: String?
    let createdAt: Date
    var kycStatus: String? // Gerçek KYC takibi için eklendi

    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case fullName      = "full_name"
        case walletAddress = "wallet_address"
        case createdAt     = "created_at"
        case kycStatus     = "kyc_status"
    }

    var isKYCApproved: Bool {
        kycStatus == "verified"
    }
    
    var displayName: String {
        if let name = fullName, !name.isEmpty { return name }
        return email
    }
    
    var initials: String {
        let nameToSplit = (fullName ?? email)
        let parts = nameToSplit.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(nameToSplit.prefix(2)).uppercased()
    }
}

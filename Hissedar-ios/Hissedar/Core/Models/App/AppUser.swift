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

    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case fullName      = "full_name"
        case walletAddress = "wallet_address"
        case createdAt     = "created_at"
    }

    var isKYCApproved: Bool { true }
    var displayName: String { fullName ?? email }
    var initials: String {
        let parts = (fullName ?? email).split(separator: " ")
        if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
        return String((fullName ?? email).prefix(2)).uppercased()
    }
}

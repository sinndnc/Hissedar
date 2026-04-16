//
//  ProfileCardModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import Foundation
import SwiftUI

struct ProfileCard: Hashable {
    var icon: String
    var title: String
    var destination: ProfileDestination
    
    static var generalItems: [ProfileCard] {
        [
            ProfileCard(
                icon: "person.crop.circle",
                title: "Profile",
                destination: .profile
            ),
            ProfileCard(
                icon: "list.bullet",
                title: "Notifications",
                destination: .notifications
            ),
            ProfileCard(
                icon: "moon",
                title: "theme",
                destination: .theme
            )
        ]
    }
    
    static var featuresItems: [ProfileCard] {
        [
            ProfileCard(
                icon: "bell",
                title: "Alarms",
                destination: .alarms
            ),
            ProfileCard(
                icon: "plus",
                title: "Add Asset",
                destination: .addProperty
            ),
            ProfileCard(
                icon: "wallet.bifold",
                title: "Wallets",
                destination: .wallets
            ),
            ProfileCard(
                icon: "banknote",
                title: "Rent Incomes",
                destination: .rents
            ),
            ProfileCard(
                icon: "document.badge.clock",
                title: "Transactions",
                destination: .transactions
            )
        ]
    }
    
    static var securityItems: [ProfileCard] {
        [
            ProfileCard(
                icon: "lock.shield",
                title: "Güvenlik",
                destination: .security
            ),
            ProfileCard(
                icon: "questionmark.circle",
                title: "Yardım ve Destek",
                destination: .support
            ),
            ProfileCard(
                icon: "doc.text",
                title: "Gizlilik Politikası",
                destination: .privacyPolicy
            ),
        ]
    }
}

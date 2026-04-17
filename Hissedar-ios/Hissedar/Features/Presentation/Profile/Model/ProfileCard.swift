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
                title: String.localized("profile.general.section.profile"),
                destination: .profile
            ),
            ProfileCard(
                icon: "list.bullet",
                title: String.localized("profile.general.section.notification"),
                destination: .notifications
            ),
            ProfileCard(
                icon: "moon",
                title: String.localized("profile.general.section.theme"),
                destination: .theme
            ),
            ProfileCard(
                icon: "globe",
                title: String.localized("profile.general.section.language"),
                destination: .language
            )
        ]
    }
    
    static var featuresItems: [ProfileCard] {
        [
            ProfileCard(
                icon: "bell",
                title: String.localized("profile.asset.section.alarm"),
                destination: .alarms
            ),
            ProfileCard(
                icon: "plus",
                title: String.localized("profile.asset.section.add.asset"),
                destination: .addProperty
            ),
            ProfileCard(
                icon: "wallet.bifold",
                title: String.localized("profile.asset.section.wallet"),
                destination: .wallets
            ),
            ProfileCard(
                icon: "banknote",
                title: String.localized("profile.asset.section.rent.income"),
                destination: .rents
            ),
            ProfileCard(
                icon: "document.badge.clock",
                title: String.localized("profile.asset.section.transaction"),
                destination: .transactions
            )
        ]
    }
    
    static var securityItems: [ProfileCard] {
        [
            ProfileCard(
                icon: "lock.shield",
                title: String.localized("profile.security.section.security"),
                destination: .security
            ),
            ProfileCard(
                icon: "questionmark.circle",
                title: String.localized("profile.security.section.support"),
                destination: .support
            ),
            ProfileCard(
                icon: "doc.text",
                title: String.localized("profile.security.section.policy"),
                destination: .privacyPolicy
            ),
        ]
    }
}

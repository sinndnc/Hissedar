//
//  ProfileCardView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI

struct ProfileCardView: View {
    
    let item: ProfileCard
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Label {
            Text(item.title)
                .foregroundStyle(themeManager.theme.textPrimary)
                .font(.system(size: 14,weight: .semibold))
        } icon: {
            Image(systemName: item.icon)
                .foregroundStyle(themeManager.theme.textPrimary)
                .font(.system(size: 14,weight: .semibold))
        }
    }
}

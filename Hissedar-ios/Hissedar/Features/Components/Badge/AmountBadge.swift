//
//  AmountBadge.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct AmountBadge: View {
    
    let price: String
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Text(price)
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(themeManager.theme.textPrimary)
    }
}

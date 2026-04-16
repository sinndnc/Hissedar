//
//  ChangeBadge.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct ChangeBadge: View {
    let change: String
    let isPositive: Bool

    var body: some View {
        Text(change)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundColor(isPositive ? Color.hsSuccess : Color.hsError)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background((isPositive ? Color.hsSuccess : Color.hsError).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

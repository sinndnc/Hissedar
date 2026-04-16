//
//  SectionHeaderView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/25/26.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let actionTitle: String?
    var action: (() -> Void)?
    
    init(_ title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.hsTextPrimary)
            
            Spacer()
            
            if let actionTitle {
                Button {
                    action?()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.hsPurple400)
                }
            }
        }
        .padding(.horizontal)
    }
}

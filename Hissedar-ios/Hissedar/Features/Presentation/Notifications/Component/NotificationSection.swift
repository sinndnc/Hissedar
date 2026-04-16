//
//  NotificationSection.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct NotificationSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .padding(.horizontal)
                .foregroundStyle(Color.hsTextPrimary)
                .font(.system(size: 14,weight: .semibold))
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.hsBackgroundSecondary)
        }
    }
}

//
//  ProfileCardView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI

struct ProfileCardView: View {
    
    let item: ProfileCard
    
    var body: some View {
        Label {
            Text(item.title)
                .foregroundStyle(Color.hsTextPrimary)
                .font(.system(size: 14,weight: .semibold))
        } icon: {
            Image(systemName: item.icon)
                .foregroundStyle(Color.hsTextPrimary)
                .font(.system(size: 14,weight: .semibold))
        }
    }
}

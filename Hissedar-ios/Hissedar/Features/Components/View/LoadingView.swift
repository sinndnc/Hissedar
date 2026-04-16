//
//  LoadingView.swift
//  Hissedar
//

import SwiftUI

struct LoadingView: View {

    var body: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100,height: 100)
                .background(Color.hsBackgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hsBackground.opacity(0.1))
    }
}

#Preview {
    LoadingView()
        .background(Color.hsBackground)
}

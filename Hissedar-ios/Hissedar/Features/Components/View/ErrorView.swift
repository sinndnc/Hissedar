//
//  ErrorView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40)).foregroundStyle(Color.hsError)
            Text(message)
                .font(.hBody)
                .foregroundStyle(Color.hsTextPrimary)
                .multilineTextAlignment(.center)
            Button("Tekrar Dene", action: retry)
                .font(.hBodyMedium).foregroundStyle(Color.hsTextPrimary)
        }
        .padding(32).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//
//  WalletEmptyView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/30/26.
//

import SwiftUI

struct WalletEmptyView: View {
    let onImport: () -> Void
    let onCreate: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("No Wallets", systemImage: "wallet.pass")
        } description: {
            Text("Import an existing wallet or create a new one to get started.")
        } actions: {
            Button("Import Wallet", action: onImport)
                .buttonStyle(.borderedProminent)
            Button("Create New", action: onCreate)
                .buttonStyle(.bordered)
        }
    }
}

//
//  LoadingOverlayView.swift
//  Hissedar
//

struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

//
//  RegisterView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Foundation
import SwiftUI

// MARK: - Register
struct RegisterView: View {
    @EnvironmentObject var vm: AuthViewModel
    var onRegistered: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ZStack {
                        Color.hForest.ignoresSafeArea(edges: .top)
                        VStack(spacing: 8) {
                            HissedarLogoView(size: 48, foreground: .hMint)
                            Text("Hesap Oluştur")
                                .font(.hTitle).foregroundStyle(Color.hWhite)
                            Text("Küçük yatırımla büyük mülklere ortak ol")
                                .font(.hCaption).foregroundStyle(Color.hMint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60).padding(.bottom, 36)
                    }
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 14) {
                            HTextField(label: "Ad Soyad",
                                       placeholder: "Adınız Soyadınız",
                                       text: $vm.fullName)
                            HTextField(label: "E-posta",
                                       placeholder: "ornek@email.com",
                                       text: $vm.email,
                                       keyboardType: .emailAddress)
                            HTextField(label: "Şifre",
                                       placeholder: "En az 8 karakter",
                                       text: $vm.password,
                                       isSecure: true)
                        }
                        
                        if let err = vm.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(err).font(.hCaption)
                            }
                            .foregroundStyle(Color.hRust)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            Task { await vm.register(); if vm.errorMessage == nil { onRegistered?() } }
                        } label: {
                            Group {
                                if vm.isLoading { ProgressView().tint(.white) }
                                else            { Text("Hesap Oluştur") }
                            }
                        }
                        .disabled(vm.isLoading)
                        
                        Text("Kaydolarak Kullanım Koşullarını kabul etmiş olursunuz.")
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    
                    HStack(spacing: 4) {
                        Text("Zaten hesabın var mı?")
                            .font(.hCaption).foregroundStyle(Color.hsTextPrimary)
                        Button("Giriş Yap") { vm.isRegistering = false }
                            .font(.hCaptionMed).foregroundStyle(Color.hEmerald)
                    }
                    .padding(.top, 28).padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

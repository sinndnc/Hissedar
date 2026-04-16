//
//  LoginView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var showReset = false
    
    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Hero header
                    ZStack(alignment: .bottom) {
                        Color.hForest.ignoresSafeArea(edges: .top)
                        VStack(spacing: 10) {
                            HissedarLogoView(size: 56, foreground: .hMint)
                            Text("Hissedar")
                                .font(.hDisplay)
                                .foregroundStyle(Color.hWhite)
                            Text("Gayrimenkul yatırımında yeni dönem")
                                .font(.hCaption)
                                .foregroundStyle(Color.hMint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.bottom, 36)
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28)
                            .offset(y: -28)
                            .inset(by: -28)
                    )
                    
                    // Form
                    VStack(spacing: 20) {
                        VStack(spacing: 14) {
                            HTextField(label: "E-posta",
                                       placeholder: "ornek@email.com",
                                       text: $vm.email,
                                       keyboardType: .emailAddress)
                            HTextField(label: "Şifre",
                                       placeholder: "••••••••",
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
                            Task { await vm.login() }
                        } label: {
                            Group {
                                if vm.isLoading { ProgressView().tint(.white) }
                                else            { Text("Giriş Yap") }
                            }
                        }
                        .disabled(vm.isLoading)
                        
                        Button("Şifremi unuttum") { showReset = true }
                            .font(.hCaption)
                            .foregroundStyle(Color.hEmerald)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    
                    // Kayıt ol
                    HStack(spacing: 4) {
                        Text("Hesabın yok mu?")
                            .font(.hCaption).foregroundStyle(Color.hsTextPrimary)
                        Button("Kayıt Ol") { vm.isRegistering = true }
                            .font(.hCaptionMed).foregroundStyle(Color.hEmerald)
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Şifre Sıfırlama", isPresented: $showReset) {
            TextField("E-posta", text: $vm.email).keyboardType(.emailAddress).autocapitalization(.none)
            Button("Gönder") { Task { await vm.resetPassword() } }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Şifre sıfırlama bağlantısı gönderilecek.")
        }
    }
}

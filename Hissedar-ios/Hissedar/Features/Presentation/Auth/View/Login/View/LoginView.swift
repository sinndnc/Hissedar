//
//  LoginView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

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
                        Color.hsBackground.ignoresSafeArea(edges: .top)
                        VStack(spacing: 10) {
                            HissedarLogoView(size: 56)
                            Text(String.localized("common.app_name"))
                                .font(.hDisplay)
                                .foregroundStyle(Color.hsTextPrimary)
                            Text(String.localized("auth.login.subtitle"))
                                .font(.hCaption)
                                .foregroundStyle(Color.hsTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.bottom, 36)
                    }
                    
                    // Form
                    VStack(spacing: 20) {
                        VStack(spacing: 14) {
                            HTextField(label: String.localized("auth.field.email"),
                                       placeholder: "ornek@email.com",
                                       text: $vm.email,
                                       keyboardType: .emailAddress)
                            HTextField(label: String.localized("auth.field.password"),
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
                            .foregroundStyle(Color.hsError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            Task { await vm.login() }
                        } label: {
                            Group {
                                if vm.isLoading { ProgressView().tint(.white) }
                                else            { Text(String.localized("auth.login.action")) }
                            }
                        }
                        .disabled(vm.isLoading)
                        
                        Button(String.localized("auth.login.forgot_password")) { showReset = true }
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    
                    // Kayıt ol
                    HStack(spacing: 4) {
                        Text(String.localized("auth.login.no_account"))
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextSecondary)
                        Button(String.localized("auth.register.title")) { vm.isRegistering = true }
                            .font(.hCaptionMed)
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert(String.localized("auth.reset.title"), isPresented: $showReset) {
            TextField(String.localized("auth.field.email"), text: $vm.email).keyboardType(.emailAddress).autocapitalization(.none)
            Button(String.localized("common.send")) { Task { await vm.resetPassword() } }
            Button(String.localized("common.cancel"), role: .cancel) {}
        } message: {
            Text(String.localized("auth.reset.message"))
        }
    }
}

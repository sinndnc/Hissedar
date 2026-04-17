//
//  RegisterView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var vm: AuthViewModel
    var onRegistered: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ZStack {
                        Color.hsBackground.ignoresSafeArea(edges: .top)
                        VStack(spacing: 8) {
                            HissedarLogoView(size: 48)
                            Text(String.localized("auth.register.title"))
                                .font(.hTitle)
                                .foregroundStyle(Color.hsTextPrimary)
                            Text(String.localized("auth.register.subtitle"))
                                .font(.hCaption)
                                .foregroundStyle(Color.hsTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60).padding(.bottom, 36)
                    }
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 14) {
                            HTextField(label: String.localized("auth.field.fullname"),
                                       placeholder: String.localized("auth.field.fullname_placeholder"),
                                       text: $vm.fullName)
                            HTextField(label: String.localized("auth.field.email"),
                                       placeholder: "ornek@email.com",
                                       text: $vm.email,
                                       keyboardType: .emailAddress)
                            HTextField(label: String.localized("auth.field.password"),
                                       placeholder: String.localized("auth.field.password_hint"),
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
                            Task { await vm.register(); if vm.errorMessage == nil { onRegistered?() } }
                        } label: {
                            Group {
                                if vm.isLoading { ProgressView().tint(.white) }
                                else            { Text(String.localized("auth.register.action")) }
                            }
                        }
                        .disabled(vm.isLoading)
                        
                        Text(String.localized("auth.register.terms_agreement"))
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    
                    HStack(spacing: 4) {
                        Text(String.localized("auth.register.has_account"))
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextSecondary)
                        Button(String.localized("auth.login.title")) { vm.isRegistering = false }
                            .font(.hCaptionMed)
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                    .padding(.top, 28).padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

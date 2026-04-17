//
//  KYCFlowView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

// MARK: - KYC Flow View
struct KYCFlowView: View {
    
    @Binding var kycStatus: KYCStatus
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: KYCStep = .intro
    @State private var isLoading = false
    @State private var kycFormURL: URL?
    @State private var errorMessage: String?
    
    enum KYCStep {
        case intro
        case webView
        case processing
        case result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.hsBackground.ignoresSafeArea()
                
                switch currentStep {
                case .intro:
                    kycIntroView
                case .webView:
                    kycWebViewStep
                case .processing:
                    kycProcessingView
                case .result:
                    kycResultView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String.localized("kyc.nav_title"))
                        .font(.hHeadline)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Intro View
    private var kycIntroView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Hero illustration
                ZStack {
                    Circle()
                        .fill(Color.hsTextSecondary.opacity(0.08))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color.hsTextSecondary.opacity(0.12))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.hsTextSecondary)
                }
                .padding(.top, 24)
                
                // Title & Subtitle
                VStack(spacing: 12) {
                    Text(String.localized("kyc.intro.title"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    Text(String.localized("kyc.intro.desc"))
                        .font(.hBody)
                        .foregroundStyle(Color.hsTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Steps
                VStack(spacing: 0) {
                    KYCInfoStepRow(
                        step: 1,
                        icon: "person.text.rectangle",
                        title: String.localized("kyc.step1.title"),
                        description: String.localized("kyc.step1.desc"),
                        isLast: false
                    )
                    
                    KYCInfoStepRow(
                        step: 2,
                        icon: "camera.viewfinder",
                        title: String.localized("kyc.step2.title"),
                        description: String.localized("kyc.step2.desc"),
                        isLast: false
                    )
                    
                    KYCInfoStepRow(
                        step: 3,
                        icon: "faceid",
                        title: String.localized("kyc.step3.title"),
                        description: String.localized("kyc.step3.desc"),
                        isLast: true
                    )
                }
                .padding(.horizontal, 20)
                
                // Info note
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.hsTextSecondary)
                        .padding(.top, 2)
                    
                    Text(String.localized("kyc.intro.security_note"))
                        .font(.hLabel)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.hsTextSecondary.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.hsTextSecondary.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // Error message
                if let errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.hsError)
                        Text(errorMessage)
                            .font(.hLabel)
                            .foregroundStyle(Color.hsError)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.hsError.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                }
                
                // Start Button
                Button {
                    startKYC()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(Color.hsTextSecondary)
                        } else {
                            Text(String.localized("kyc.intro.button_start"))
                                .font(.hBodyMedium)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(Color.hsTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hsTextSecondary)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .padding(.horizontal, 20)
                
                // Estimated time
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(String.localized("kyc.intro.est_time"))
                        .font(.hLabel)
                }
                .foregroundStyle(Color.hsTextPrimary)
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - WebView Step (Kycaid)
    private var kycWebViewStep: some View {
        VStack {
            if let url = kycFormURL {
                KYCWebViewPlaceholder(url: url) {
                    withAnimation {
                        currentStep = .processing
                        kycStatus = .pending
                    }
                }
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(Color.hsTextSecondary)
                    Text(String.localized("common.loading"))
                        .font(.hBody)
                        .foregroundStyle(Color.hsTextPrimary)
                }
            }
        }
    }
    
    // MARK: - Processing View
    private var kycProcessingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.hsPurple600.opacity(0.08))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(Color.hsPurple600.opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "hourglass")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.hsPurple600)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            VStack(spacing: 12) {
                Text(String.localized("kyc.processing.title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hsTextPrimary)
                
                Text(String.localized("kyc.processing.desc"))
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(String.localized("common.ok"))
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hsTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hsTextSecondary)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Result View
    private var kycResultView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            let isVerified = kycStatus == .verified
            
            ZStack {
                Circle()
                    .fill((isVerified ? Color.hsTextSecondary : Color.hsError).opacity(0.08))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill((isVerified ? Color.hsTextSecondary : Color.hsError).opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: isVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(isVerified ? Color.hsTextSecondary : Color.hsError)
            }
            
            VStack(spacing: 12) {
                Text(isVerified ? String.localized("kyc.result.success_title") : String.localized("kyc.result.fail_title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hsTextPrimary)
                
                Text(isVerified
                     ? String.localized("kyc.result.success_desc")
                     : String.localized("kyc.result.fail_desc"))
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                if !isVerified {
                    Button {
                        withAnimation {
                            currentStep = .intro
                            errorMessage = nil
                        }
                    } label: {
                        Text(String.localized("common.retry"))
                            .font(.hBodyMedium)
                            .foregroundStyle(Color.hsTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.hsError)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text(isVerified ? String.localized("common.ok") : String.localized("common.close"))
                        .font(.hBodyMedium)
                        .foregroundStyle(
                            isVerified ? Color.hsTextSecondary : Color.hsTextPrimary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isVerified ? Color.hsTextSecondary : Color.hsBackgroundSecondary)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Actions
    private func startKYC() {
        isLoading = true
        errorMessage = nil
        
        // Mock: Simüle edilmiş yükleme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            kycFormURL = URL(string: "https://app.kycaid.com/form/example")
            withAnimation {
                currentStep = .webView
            }
        }
    }
}

// MARK: - KYC Info Step Row
struct KYCInfoStepRow: View {
    let step: Int
    let icon: String
    let title: String
    let description: String
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step indicator with line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.hsTextSecondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("\(step)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.hsTextSecondary)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.hsTextSecondary.opacity(0.15))
                        .frame(width: 2, height: 32)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.hsTextSecondary)
                    
                    Text(title)
                        .font(.hBodyMedium)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                Text(description)
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            .padding(.top, 6)
            
            Spacer()
        }
    }
}

// MARK: - Placeholder WebView
struct KYCWebViewPlaceholder: View {
    let url: URL
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hsTextSecondary)
                
                Text(String.localized("kyc.webview.mock_title"))
                    .font(.hHeadline)
                    .foregroundStyle(Color.hsTextPrimary)
                
                Text(String.localized("kyc.webview.mock_desc"))
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(url.absoluteString)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.hsTextSecondary.opacity(0.6))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(Color.hsTextSecondary.opacity(0.3))
                    )
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                onComplete()
            } label: {
                Text(String.localized("kyc.webview.mock_button"))
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hsTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hsPurple600)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

//
//  IBANEditorView.swift
//  Hissedar
//

import SwiftUI

// MARK: - IBAN Editor Sheet
struct IBANEditorView: View {
    @Binding var iban: String
    @Environment(\.dismiss) private var dismiss
    @State private var editedIBAN = ""
    @State private var isValid = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String.localized("iban.field.label"))
                        .font(.hCaptionMed)
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    TextField("TR00 0000 0000 0000 0000 0000 00", text: $editedIBAN)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundStyle(Color.hsTextPrimary)
                        .tint(Color.hsTextSecondary)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.hsBackgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isValid ? Color.hsTextSecondary
                                                .opacity(0.3) : Color.hsTextPrimary
                                                .opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.allCharacters)
                        .onChange(of: editedIBAN) { _, newValue in
                            let cleaned = newValue.replacingOccurrences(of: " ", with: "")
                            isValid = cleaned.count == 26 && cleaned.hasPrefix("TR")
                        }
                    
                    if !editedIBAN.isEmpty && !isValid {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 11))
                            Text(String.localized("iban.error.invalid"))
                                .font(.hLabel)
                        }
                        .foregroundStyle(Color.hsError)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                Spacer()
                
                Button {
                    iban = editedIBAN.replacingOccurrences(of: " ", with: "")
                    dismiss()
                } label: {
                    Text(String.localized("common.save"))
                        .font(.hBodyMedium)
                        .foregroundStyle(Color.hsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isValid ? Color.hsTextSecondary : Color.hsTextSecondary.opacity(0.4))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isValid)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color.hsBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String.localized("iban.editor.title"))
                        .font(.hHeadline)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(String.localized("common.cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(Color.hsTextPrimary)
                }
            }
            .onAppear {
                editedIBAN = iban
                let cleaned = iban.replacingOccurrences(of: " ", with: "")
                isValid = cleaned.count == 26 && cleaned.hasPrefix("TR")
            }
        }
    }
}

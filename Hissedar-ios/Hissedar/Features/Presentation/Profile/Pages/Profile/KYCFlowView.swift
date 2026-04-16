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
                    Text("Kimlik Doğrulama")
                        .font(.hHeadline)
                        .foregroundStyle(Color.hWhite)
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
                        .fill(Color.hJade.opacity(0.08))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color.hJade.opacity(0.12))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.hJade)
                }
                .padding(.top, 24)
                
                // Title & Subtitle
                VStack(spacing: 12) {
                    Text("Kimliğinizi Doğrulayın")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.hWhite)
                    
                    Text("Yatırım yapabilmek için MASAK düzenlemelerine uygun kimlik doğrulaması gereklidir.")
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
                        title: "Kimlik Bilgileri",
                        description: "TC Kimlik numaranız ve kişisel bilgileriniz",
                        isLast: false
                    )
                    
                    KYCInfoStepRow(
                        step: 2,
                        icon: "camera.viewfinder",
                        title: "Belge Fotoğrafı",
                        description: "Kimlik kartınızın ön ve arka yüzü",
                        isLast: false
                    )
                    
                    KYCInfoStepRow(
                        step: 3,
                        icon: "faceid",
                        title: "Yüz Doğrulama",
                        description: "Canlılık kontrolü için selfie çekimi",
                        isLast: true
                    )
                }
                .padding(.horizontal, 20)
                
                // Info note
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.hJade)
                        .padding(.top, 2)
                    
                    Text("Bilgileriniz 256-bit SSL şifreleme ile korunmaktadır ve yalnızca yasal zorunluluklar kapsamında kullanılır.")
                        .font(.hLabel)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.hJade.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.hJade.opacity(0.1), lineWidth: 1)
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
                                .tint(Color.hCharcoal)
                        } else {
                            Text("Doğrulamayı Başlat")
                                .font(.hBodyMedium)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(Color.hCharcoal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hJade)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .padding(.horizontal, 20)
                
                // Estimated time
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("Tahmini süre: 3-5 dakika")
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
                // TODO: KycaidWebView(url: url) ile değiştir
                // WKWebView based Kycaid form burada yüklenir
                KYCWebViewPlaceholder(url: url) {
                    // onComplete callback
                    withAnimation {
                        currentStep = .processing
                        kycStatus = .pending
                    }
                }
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(Color.hJade)
                    Text("Form yükleniyor...")
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
            
            ZStack {
                Circle()
                    .fill(Color.hGold.opacity(0.08))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(Color.hGold.opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "hourglass")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.hGold)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            VStack(spacing: 12) {
                Text("Doğrulama İnceleniyor")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hWhite)
                
                Text("Bilgileriniz inceleniyor. Bu işlem genellikle birkaç dakika sürer. Sonuç bildirim olarak gönderilecektir.")
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Tamam")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hCharcoal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hJade)
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
                    .fill((isVerified ? Color.hJade : Color.hsError).opacity(0.08))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill((isVerified ? Color.hJade : Color.hsError).opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: isVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(isVerified ? Color.hJade : Color.hsError)
            }
            
            VStack(spacing: 12) {
                Text(isVerified ? "Doğrulama Tamamlandı!" : "Doğrulama Başarısız")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hWhite)
                
                Text(isVerified
                     ? "Hesabınız başarıyla doğrulandı. Artık yatırım yapabilirsiniz."
                     : "Doğrulama işlemi başarısız oldu. Lütfen tekrar deneyin veya destek ekibimize ulaşın.")
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
                        Text("Tekrar Dene")
                            .font(.hBodyMedium)
                            .foregroundStyle(Color.hCharcoal)
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
                    Text(isVerified ? "Tamam" : "Kapat")
                        .font(.hBodyMedium)
                        .foregroundStyle(isVerified ? Color.hCharcoal : Color.hWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isVerified ? Color.hJade : Color.hsBackgroundSecondary)
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
        
        // TODO: Kycaid Edge Function çağrısı
        // KYCService.shared.getFormURL { result in
        //     switch result {
        //     case .success(let url):
        //         kycFormURL = url
        //         currentStep = .webView
        //     case .failure(let error):
        //         errorMessage = error.localizedDescription
        //     }
        //     isLoading = false
        // }
        
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
                        .fill(Color.hJade.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("\(step)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.hJade)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.hJade.opacity(0.15))
                        .frame(width: 2, height: 32)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.hJade)
                    
                    Text(title)
                        .font(.hBodyMedium)
                        .foregroundStyle(Color.hWhite)
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

// MARK: - Placeholder WebView (replace with actual WKWebView)
struct KYCWebViewPlaceholder: View {
    let url: URL
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hJade)
                
                Text("Kycaid Formu")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
                
                Text("Burada WKWebView ile Kycaid formu yüklenecek")
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(url.absoluteString)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.hJade.opacity(0.6))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(Color.hJade.opacity(0.3))
                    )
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Simulated complete button (dev only)
            Button {
                onComplete()
            } label: {
                Text("Doğrulamayı Tamamla (Test)")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hCharcoal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hGold)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

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
                    Text("IBAN Numaranız")
                        .font(.hCaptionMed)
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    TextField("TR00 0000 0000 0000 0000 0000 00", text: $editedIBAN)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundStyle(Color.hWhite)
                        .tint(Color.hJade)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.hsBackgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isValid ? Color.hJade.opacity(0.3) : Color.hWhite.opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.allCharacters)
                        .onChange(of: editedIBAN) { _, newValue in
                            // Basic TR IBAN validation (26 chars)
                            let cleaned = newValue.replacingOccurrences(of: " ", with: "")
                            isValid = cleaned.count == 26 && cleaned.hasPrefix("TR")
                        }
                    
                    if !editedIBAN.isEmpty && !isValid {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 11))
                            Text("Geçerli bir TR IBAN numarası girin (26 karakter)")
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
                    Text("Kaydet")
                        .font(.hBodyMedium)
                        .foregroundStyle(Color.hCharcoal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isValid ? Color.hJade : Color.hJade.opacity(0.4))
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
                    Text("IBAN Düzenle")
                        .font(.hHeadline)
                        .foregroundStyle(Color.hWhite)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Vazgeç") {
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

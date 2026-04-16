import SwiftUI

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showImagePicker = false
    @State private var showKYCView = false
    @State private var showIBANEditor = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                avatarSection
                kycStatusBanner
                personalInfoSection
                financialInfoSection
                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profil Bilgileri")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
        .sheet(isPresented: $showKYCView) {
            KYCFlowView(kycStatus: $viewModel.kycStatus)
        }
        .sheet(isPresented: $showIBANEditor) {
            IBANEditorView(iban: $viewModel.iban)
        }
        .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
            Button("Vazgeç", role: .cancel) { }
            Button("Çıkış Yap", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
    
    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 16) {
            Button {
                showImagePicker = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.hJade.opacity(0.3), Color.hEmerald.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        if let initials = viewModel.initials {
                            Text(initials)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.hWhite)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(Color.hWhite.opacity(0.6))
                        }
                    }
                    
                    // Camera badge
                    ZStack {
                        Circle()
                            .fill(Color.hJade)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.hCharcoal)
                    }
                    .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 4) {
                Text(viewModel.fullName)
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                
                kycBadgeLabel
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var kycBadgeLabel: some View {
        switch viewModel.kycStatus {
        case .verified:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hJade)
                Text("Doğrulanmış Hesap")
                    .font(.hLabel)
                    .foregroundStyle(Color.hJade)
            }
        case .pending:
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hGold)
                Text("Doğrulama Bekleniyor")
                    .font(.hLabel)
                    .foregroundStyle(Color.hGold)
            }
        case .rejected:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hsError)
                Text("Doğrulama Reddedildi")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsError)
            }
        case .notStarted:
            HStack(spacing: 4) {
                Image(systemName: "person.badge.clock")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hsTextPrimary)
                Text("Doğrulama Gerekli")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
        }
    }
    
    // MARK: - KYC Status Banner
    @ViewBuilder
    private var kycStatusBanner: some View {
        switch viewModel.kycStatus {
        case .verified:
            kycVerifiedBanner
        case .pending:
            kycPendingBanner
        case .rejected:
            kycRejectedBanner
        case .notStarted:
            kycStartBanner
        }
    }
    
    private var kycVerifiedBanner: some View {
        Button {
            showKYCView = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.hJade.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.hJade)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("KYC Doğrulaması Tamamlandı")
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                    
                    Text("MASAK uyumlu kimlik doğrulaması aktif")
                        .font(.hLabel)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.hJade.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var kycPendingBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.hGold.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "hourglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.hGold)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Doğrulama İnceleniyor")
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Text("Kimlik doğrulama süreci devam ediyor")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.hsBackgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.hGold.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private var kycRejectedBanner: some View {
        Button {
            showKYCView = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.hsError.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "xmark.shield.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.hsError)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Doğrulama Reddedildi")
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                    
                    Text("Tekrar deneyin veya destek ile iletişime geçin")
                        .font(.hLabel)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                Spacer()
                
                Text("Tekrarla")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsError)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(Color.hsError.opacity(0.12))
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.hsError.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var kycStartBanner: some View {
        Button {
            showKYCView = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.hJade.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.hJade)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Kimlik Doğrulaması Gerekli")
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                    
                    Text("Yatırım yapmak için KYC doğrulamasını tamamlayın")
                        .font(.hLabel)
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.hJade)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.hJade.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Personal Info
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Kişisel Bilgiler")
            
            VStack(spacing: 0) {
                ProfileInfoRow(
                    icon: "person.fill",
                    label: "Ad Soyad",
                    value: viewModel.fullName,
                    color: .hJade,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.fullName)
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                        .tint(Color.hJade)
                }
                
                ProfileDivider()
                
                ProfileInfoRow(
                    icon: "envelope.fill",
                    label: "E-posta",
                    value: viewModel.email,
                    color: .hGold,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.email)
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                        .tint(Color.hJade)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                ProfileDivider()
                
                ProfileInfoRow(
                    icon: "phone.fill",
                    label: "Telefon",
                    value: viewModel.phone,
                    color: .hMint,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.phone)
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                        .tint(Color.hJade)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                
                ProfileDivider()
                
                // TC Kimlik - Read only, masked
                ProfileInfoRow(
                    icon: "person.text.rectangle.fill",
                    label: "TC Kimlik No",
                    value: viewModel.maskedTCNo,
                    color: .hSilver,
                    isEditable: false,
                    isLocked: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Financial Info
    private var financialInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Finansal Bilgiler")
            
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    IconBadge(icon: "creditcard.fill", color: .hGold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("IBAN")
                            .font(.hLabel)
                            .foregroundStyle(Color.hsTextPrimary)
                        
                        if viewModel.iban.isEmpty {
                            Text("Henüz eklenmedi")
                                .font(.hBody)
                                .foregroundStyle(Color.hWhite.opacity(0.3))
                        } else {
                            Text(viewModel.maskedIBAN)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(Color.hWhite)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        showIBANEditor = true
                    } label: {
                        Text(viewModel.iban.isEmpty ? "Ekle" : "Düzenle")
                            .font(.hLabel)
                            .foregroundStyle(Color.hJade)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            viewModel.saveProfile()
        } label: {
            HStack(spacing: 8) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(Color.hCharcoal)
                } else {
                    Text("Değişiklikleri Kaydet")
                        .font(.hBodyMedium)
                }
            }
            .foregroundStyle(Color.hCharcoal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        viewModel.hasChanges
                            ? Color.hJade
                            : Color.hJade.opacity(0.4)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.hasChanges || viewModel.isSaving)
        .animation(.easeInOut(duration: 0.2), value: viewModel.hasChanges)
    }
}

// MARK: - Reusable Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.hCaptionMed)
            .foregroundStyle(Color.hsTextPrimary)
            .padding(.leading, 4)
    }
}

struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 38
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.12))
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

struct ProfileDivider: View {
    var body: some View {
        Divider()
            .background(Color.hWhite.opacity(0.06))
            .padding(.leading, 68)
    }
}

struct ProfileInfoRow<Content: View>: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var isEditable: Bool = false
    var isLocked: Bool = false
    let content: Content
    
    init(
        icon: String,
        label: String,
        value: String,
        color: Color,
        isEditable: Bool = false,
        isLocked: Bool = false,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
        self.isEditable = isEditable
        self.isLocked = isLocked
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon, color: color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
                
                if isEditable, !(content is EmptyView) {
                    content
                } else {
                    Text(value)
                        .font(.hBody)
                        .foregroundStyle(
                            isLocked
                                ? Color.hWhite.opacity(0.5)
                                : Color.hWhite
                        )
                }
            }
            
            Spacer()
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hsTextPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct AccountActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(icon: icon, color: color)
                
                Text(title)
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

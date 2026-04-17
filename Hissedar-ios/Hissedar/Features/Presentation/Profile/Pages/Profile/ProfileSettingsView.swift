import SwiftUI
import Factory

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showImagePicker = false
    @State private var showKYCView = false
    @State private var showIBANEditor = false
    @State private var showLogoutAlert = false
    
    @Environment(ThemeManager.self) private var themeManager
    
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
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("profile.settings.nav_title"))
                    .font(.hHeadline)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
        .sheet(isPresented: $showKYCView) {
            KYCFlowView(kycStatus: $viewModel.kycStatus)
        }
        .sheet(isPresented: $showIBANEditor) {
            IBANEditorView(iban: $viewModel.iban)
        }
        .alert(String.localized("profile.settings.logout.title"), isPresented: $showLogoutAlert) {
            Button(String.localized("common.cancel"), role: .cancel) { }
            Button(String.localized("profile.settings.logout.confirm"), role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text(String.localized("profile.settings.logout.message"))
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
                            .fill(themeManager.theme.backgroundSecondary)
                            .frame(width: 100, height: 100)
                        
                        if let initials = viewModel.initials {
                            Text(initials)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(themeManager.theme.textPrimary)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(themeManager.theme.textPrimary.opacity(0.6))
                        }
                    }
                    
                    ZStack {
                        Circle()
                            .fill(themeManager.theme.textSecondary)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(themeManager.theme.accent)
                    }
                    .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 4) {
                Text(viewModel.fullName)
                    .font(.hBodyMedium)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                kycBadgeLabel
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var kycBadgeLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.kycStatus.icon)
                .font(.system(size: 11))
            Text(viewModel.kycStatus.localizedLabel)
                .font(.hLabel)
        }
        .foregroundStyle(viewModel.kycStatus == .rejected ? themeManager.theme.error : themeManager.theme.textSecondary)
    }
    
    // MARK: - KYC Status Banner
    @ViewBuilder
    private var kycStatusBanner: some View {
        Button {
            showKYCView = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.textSecondary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: viewModel.kycStatus.displayTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(viewModel.kycStatus == .rejected ? themeManager.theme.error : themeManager.theme.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.kycStatus.bannerTitle)
                        .font(.hBody)
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    Text(viewModel.kycStatus.bannerDesc)
                        .font(.hLabel)
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
                
                Spacer()
                
                if viewModel.kycStatus == .rejected {
                    Text(String.localized("common.retry"))
                        .font(.hLabel)
                        .foregroundStyle(themeManager.theme.error)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(themeManager.theme.error.opacity(0.12)))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.theme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(viewModel.kycStatus == .rejected ? themeManager.theme.error.opacity(0.2) : themeManager.theme.textSecondary.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.kycStatus == .pending)
    }
    
    // MARK: - Personal Info
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: String.localized("profile.settings.section.personal"))
            
            VStack(spacing: 0) {
                ProfileInfoRow(
                    icon: "person.fill",
                    label: String.localized("profile.settings.label.fullname"),
                    value: viewModel.fullName,
                    color: themeManager.theme.textSecondary,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.fullName)
                        .font(.hBody)
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .tint(themeManager.theme.textSecondary)
                }
                
                Divider().padding(.leading, 64)
                
                ProfileInfoRow(
                    icon: "envelope.fill",
                    label: String.localized("profile.settings.label.email"),
                    value: viewModel.email,
                    color: themeManager.theme.textSecondary,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.email)
                        .font(.hBody)
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .tint(themeManager.theme.textSecondary)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Divider().padding(.leading, 64)
                
                ProfileInfoRow(
                    icon: "phone.fill",
                    label: String.localized("profile.settings.label.phone"),
                    value: viewModel.phone,
                    color: themeManager.theme.textSecondary,
                    isEditable: true
                ) {
                    TextField("", text: $viewModel.phone)
                        .font(.hBody)
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .tint(themeManager.theme.textSecondary)
                        .keyboardType(.phonePad)
                }
                
                Divider().padding(.leading, 64)
                
                ProfileInfoRow(
                    icon: "person.text.rectangle.fill",
                    label: String.localized("profile.settings.label.tcno"),
                    value: viewModel.maskedTCNo,
                    color: themeManager.theme.textSecondary,
                    isEditable: false,
                    isLocked: true
                )
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
        }
    }
    
    // MARK: - Financial Info
    private var financialInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: String.localized("profile.settings.section.financial"))
            
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    IconBadge(icon: "creditcard.fill", color: themeManager.theme.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String.localized("profile.settings.label.iban"))
                            .font(.hLabel)
                            .foregroundStyle(themeManager.theme.textPrimary)
                        
                        if viewModel.iban.isEmpty {
                            Text(String.localized("profile.settings.iban.empty"))
                                .font(.hBody)
                                .foregroundStyle(themeManager.theme.textPrimary.opacity(0.3))
                        } else {
                            Text(viewModel.maskedIBAN)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(themeManager.theme.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        showIBANEditor = true
                    } label: {
                        Text(viewModel.iban.isEmpty ? String.localized("common.add") : String.localized("common.edit"))
                            .font(.hLabel)
                            .foregroundStyle(themeManager.theme.textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            viewModel.saveProfile()
        } label: {
            HStack(spacing: 8) {
                if viewModel.isSaving {
                    ProgressView().tint(themeManager.theme.textSecondary)
                } else {
                    Text(String.localized("profile.settings.button.save"))
                        .font(.hBodyMedium)
                }
            }
            .foregroundStyle(themeManager.theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.hasChanges ? themeManager.theme.textSecondary : themeManager.theme.textSecondary.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.hasChanges || viewModel.isSaving)
    }
}

// MARK: - Reusable Components

struct SectionHeader: View {
    let title: String
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Text(title)
            .font(.hCaptionMed)
            .foregroundStyle(themeManager.theme.textPrimary)
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

struct ProfileInfoRow<Content: View>: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var isEditable: Bool = false
    var isLocked: Bool = false
    let content: Content
    
    @Environment(ThemeManager.self) private var themeManager
    
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
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                if isEditable, !(content is EmptyView) {
                    content
                } else {
                    Text(value)
                        .font(.hBody)
                        .foregroundStyle(
                            isLocked
                            ? themeManager.theme.textPrimary.opacity(0.5)
                            : themeManager.theme.textPrimary
                        )
                }
            }
            
            Spacer()
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(themeManager.theme.textPrimary)
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
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(icon: icon, color: color)
                
                Text(title)
                    .font(.hBody)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

extension KYCStatus {
    var localizedLabel: String {
        switch self {
        case .verified: return String.localized("profile.kyc.verified")
        case .pending: return String.localized("profile.kyc.pending")
        case .rejected: return String.localized("profile.kyc.rejected")
        case .notStarted: return String.localized("profile.kyc.not_started")
        }
    }
    
    var bannerTitle: String {
        switch self {
        case .verified: return String.localized("profile.kyc.banner.verified_title")
        case .pending: return String.localized("profile.kyc.banner.pending_title")
        case .rejected: return String.localized("profile.kyc.banner.rejected_title")
        case .notStarted: return String.localized("profile.kyc.banner.start_title")
        }
    }
    
    var bannerDesc: String {
        switch self {
        case .verified: return String.localized("profile.kyc.banner.verified_desc")
        case .pending: return String.localized("profile.kyc.banner.pending_desc")
        case .rejected: return String.localized("profile.kyc.banner.rejected_desc")
        case .notStarted: return String.localized("profile.kyc.banner.start_desc")
        }
    }
}

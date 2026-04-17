import SwiftUI
import Factory

struct ProfileView: View {
    
    @Injected(\.profileViewModel) private var vm
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            List{
                Section(String.localized("profile.general.section.title")){ generalSection }
                    .listRowBackground(themeManager.theme.backgroundSecondary)
                
                Section(String.localized("profile.asset.section.title")){ featuresSection }
                    .listRowBackground(themeManager.theme.backgroundSecondary)
                
                Section(String.localized("profile.security.section.title")){ secuirtySections }
                    .listRowBackground(themeManager.theme.backgroundSecondary)
                
                Section {
                    VStack {
                        versionInfo
                        //                        signOutButton
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.grouped)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .background(themeManager.theme.background)
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationTitle(String.localized("profile.title"))
            .toolbarBackground(themeManager.theme.background, for: .navigationBar)
            .navigationDestination(for: ProfileDestination.self) { route in
                switch route {
                case .theme: ThemeView()
                case .wallets: WalletView()
                case .support: SupportView()
                case .security: SecurityView()
                case .rents: RentHistoryView()
                case .alarms: PriceAlertsListView()
                case .profile: ProfileSettingsView()
                case .transactions: TransactionsView()
                case .language: LanguageSettingsView()
                case .addProperty: AddAssetWizardView()
                case .privacyPolicy: PrivacyPolicyView()
                case .notifications: NotificationSettingsView()
                }
            }
        }
    }
    
    private var generalSection: some View {
        ForEach(ProfileCard.generalItems,id: \.self) { item in
            NavigationLink(value: item.destination){
                ProfileCardView(item: item)
            }
        }
    }
    
    // MARK: - Features Card
    private var featuresSection: some View {
        ForEach(ProfileCard.featuresItems,id: \.self) { item in
            NavigationLink(value: item.destination){
                ProfileCardView(item: item)
            }
        }
    }
    
    // MARK: - Settings Card
    private var secuirtySections: some View {
        ForEach(ProfileCard.securityItems,id: \.self) { item in
            NavigationLink(value: item.destination){
                ProfileCardView(item: item)
            }
        }
    }
    
    // MARK: - Version Info
    private var versionInfo: some View {
        VStack(spacing: 4) {
            Text("\(String.localized("common.app_name")) v1.0")
                .font(.hCaption).foregroundStyle(themeManager.theme.textPrimary)
            Text(String.localized("profile.version.copyright"))
                .font(.hLabel).foregroundStyle(themeManager.theme.textPrimary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
    
    // MARK: - Sign Out
    private var signOutButton: some View {
        Button { /*appState.signOut()*/ } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                Text(String.localized("profile.action.logout"))
                    .font(.hBodyMedium)
            }
        }
    }
    
}

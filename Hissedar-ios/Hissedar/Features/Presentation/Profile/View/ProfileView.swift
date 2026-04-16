import SwiftUI
import Factory

struct ProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Injected(\.profileViewModel) private var vm
    
    var body: some View {
        NavigationStack {
            List{
                Section("General"){ generalSection }
                    .listRowBackground(Color.hsBackgroundSecondary)
                
                Section("Properties"){ featuresSection }
                    .listRowBackground(Color.hsBackgroundSecondary)
                
                Section("Security"){ secuirtySections }
                    .listRowBackground(Color.hsBackgroundSecondary)
                
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
            .navigationTitle("Profile")
            .background(Color.hsBackground)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.hsBackground, for: .navigationBar)
//            .toolbar{ ToolbarItem(placement: .principal) { toolbarTitleItem} }
//                ToolbarItem(placement: .topBarLeading){ toolbarCloseItem}
            .navigationDestination(for: ProfileDestination.self) { route in
                switch route {
                case .theme: ThemeView()
                case .support: SupportView()
                case .security: SecurityView()
                case .rents: RentHistoryView()
                case .wallets: WalletRootView()
                case .profile: ProfileSettingsView()
                case .transactions: TransactionsView()
                case .addProperty: AddAssetWizardView()
                case .privacyPolicy: PrivacyPolicyView()
                case .notifications: NotificationSettingsView()
                }
            }
        }
    }
    
    private var toolbarTitleItem : some View {
        Text("Profil")
            .font(.hHeadline)
            .foregroundStyle(Color.hWhite)
    }
    
    private var toolbarCloseItem : some View {
        Button{ dismiss() } label:{
            Image(systemName: "xmark")
                .font(.hCaptionMed)
                .foregroundStyle(Color.hWhite)
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
            Text("Hissedar v1.0")
                .font(.hCaption).foregroundStyle(Color.hsTextPrimary)
            Text("© 2026 Hissedar. Tüm hakları saklıdır.")
                .font(.hLabel).foregroundStyle(Color.hsTextPrimary.opacity(0.5))
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
                Text("Çıkış Yap")
                    .font(.hBodyMedium)
            }
        }
    }
}

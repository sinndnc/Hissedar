//
//  NotificationSettingsView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI
import Factory

struct NotificationSettingsView: View {
    
    private var appState = Container.shared.appState()
    @State private var vm = NotificationSettingsViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                channelSection
                alertsSection
                otherSection
            }
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Bildirimler")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
        .task {
            guard let uid = appState.currentUser?.id else { return }
            await vm.load(userId: uid)
        }
        .overlay {
            if vm.isLoading {
                ProgressView()
            }
        }
    }
    
    // MARK: - Channels
    private var channelSection: some View {
        NotificationSection(title: "Bildirim Kanalları") {
            NotificationToggleRow(
                icon: "iphone",
                title: "Push Bildirimleri",
                subtitle: "Anlık bildirimler",
                isOn: Binding(
                    get: { vm.prefs.pushEnabled },
                    set: { vm.prefs.pushEnabled = $0; save() }
                ),
                accentColor: Color.hCloud
            )
        }
    }

    // MARK: - Alerts
    
    private var alertsSection: some View {
        NotificationSection(title: "Yatırım Uyarıları") {
            NotificationToggleRow(
                icon: "building.2.fill",
                title: "Kira Gelirleri",
                subtitle: "Kira yatırıldığında bildir",
                isOn: Binding(
                    get: { vm.prefs.dividendEnabled },
                    set: { vm.prefs.dividendEnabled = $0; save() }
                ),
                accentColor: .hJade
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Fiyat Değişimleri",
                subtitle: "±%\(Int(vm.prefs.priceAlertThreshold)) fiyat hareketlerinde bildir",
                isOn: Binding(
                    get: { vm.prefs.priceAlertsEnabled },
                    set: { vm.prefs.priceAlertsEnabled = $0; save() }
                ),
                accentColor: .hGold
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "star.fill",
                title: "Yeni Fırsatlar",
                subtitle: "Yeni varlık listelendiğinde bildir",
                isOn: Binding(
                    get: { vm.prefs.opportunityEnabled },
                    set: { vm.prefs.opportunityEnabled = $0; save() }
                ),
                accentColor: .hGold
            )
        }
    }

    // MARK: - Other
    
    private var otherSection: some View {
        NotificationSection(title: "Diğer") {
            NotificationToggleRow(
                icon: "gearshape.fill",
                title: "Sistem Bildirimleri",
                subtitle: "Uygulama güncellemeleri ve duyurular",
                isOn: Binding(
                    get: { vm.prefs.systemEnabled },
                    set: { vm.prefs.systemEnabled = $0; save() }
                ),
                accentColor: Color.hCloud
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "shield.fill",
                title: "Güvenlik Uyarıları",
                subtitle: "Giriş ve cihaz bildirimleri",
                isOn: Binding(
                    get: { vm.prefs.securityEnabled },
                    set: { vm.prefs.securityEnabled = $0; save() }
                ),
                accentColor: .hRust
            )
        }
    }
    
    // MARK: - Kaydet
    private func save() {
        guard let uid = appState.currentUser?.id else { return }
        Task { await vm.save(userId: uid) }
    }
}

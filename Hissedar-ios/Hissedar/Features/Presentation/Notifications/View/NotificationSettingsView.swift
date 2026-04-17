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
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                channelSection
                alertsSection
                otherSection
            }
            .padding(.bottom, 40)
        }
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("profile.notification.title"))
                    .font(.hHeadline)
                    .foregroundStyle(themeManager.theme.textPrimary)
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
        NotificationSection(title: String.localized("profile.notification.section.title")) {
            NotificationToggleRow(
                icon: "iphone",
                title: String.localized("profile.notification.push.title"),
                subtitle: String.localized("profile.notification.push.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.pushEnabled },
                    set: { vm.prefs.pushEnabled = $0; save() }
                )
            )
        }
    }

    // MARK: - Alerts
    
    private var alertsSection: some View {
        NotificationSection(title: String.localized("profile.alert.section.title")) {
            NotificationToggleRow(
                icon: "building.2.fill",
                title: String.localized("profile.alert.section.rent.income.title"),
                subtitle: String.localized("profile.alert.section.rent.income.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.dividendEnabled },
                    set: { vm.prefs.dividendEnabled = $0; save() }
                )
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "chart.line.uptrend.xyaxis",
                title: String.localized("profile.alert.section.price.changes.title"),
                subtitle:  String.localized("profile.alert.section.price.changes.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.priceAlertsEnabled },
                    set: { vm.prefs.priceAlertsEnabled = $0; save() }
                )
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "star.fill",
                title: String.localized("profile.alert.section.new.opportunities.title"),
                subtitle: String.localized("profile.alert.section.new.opportunities.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.opportunityEnabled },
                    set: { vm.prefs.opportunityEnabled = $0; save() }
                )
            )
        }
    }

    // MARK: - Other
    private var otherSection: some View {
        NotificationSection(title:  String.localized("profile.other.section.title")) {
            NotificationToggleRow(
                icon: "gearshape.fill",
                title: String.localized("profile.other.section.system.title"),
                subtitle: String.localized("profile.other.section.system.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.systemEnabled },
                    set: { vm.prefs.systemEnabled = $0; save() }
                )
            )
            
            Divider()
            
            NotificationToggleRow(
                icon: "shield.fill",
                title: String.localized("profile.other.section.security.title"),
                subtitle: String.localized("profile.other.section.security.subtitle"),
                isOn: Binding(
                    get: { vm.prefs.securityEnabled },
                    set: { vm.prefs.securityEnabled = $0; save() }
                )
            )
        }
    }
    
    // MARK: - Kaydet
    private func save() {
        guard let uid = appState.currentUser?.id else { return }
        Task { await vm.save(userId: uid) }
    }
}

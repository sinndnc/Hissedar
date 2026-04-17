//
//  HissedarApp.swift
//  Hissedar
//

import SwiftUI
import Factory

@main
struct HissedarApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private var appState = Container.shared.appState()
    
    @State private var selectedTab: AppTab = .discover
    @State private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView(selectedTab: $selectedTab)
                .environment(themeManager)
                .preferredColorScheme(
                    themeManager.currentThemeType == .dark ? .dark : .light
                )
                .onChange(of: NotificationManager.shared.pendingDeepLink) { _, link in
                    guard let link else { return }
                    handleDeepLink(link)
                    NotificationManager.shared.pendingDeepLink = nil
                }
                .onChange(of: appState.authState) { _, state in
                    handleAuthStateChange(state)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    handleForeground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    handleBackground()
                }
        }
    }
    
    // MARK: - Auth State Change
    
    private func handleAuthStateChange(_ state: AuthState) {
        switch state {
        case .authenticated:
            Task {
                // Push izni iste (3 sn gecikme — ilk açılışta boğmasın)
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await NotificationManager.shared.requestPermission()
                
                // Realtime bildirim dinlemesini başlat
                if let uid = appState.currentUser?.id {
                    await NotificationManager.shared.subscribeToRealtime(userId: uid)
                    await NotificationManager.shared.refreshUnreadCount(userId: uid)
                }
            }
        case .unauthenticated:
            Task {
                if let uid = appState.currentUser?.id {
                    await NotificationManager.shared.unregisterDeviceToken(userId: uid)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Foreground / Background
    
    private func handleForeground() {
        guard appState.authState == .authenticated,
              let uid = appState.currentUser?.id else { return }
        Task {
            await NotificationManager.shared.subscribeToRealtime(userId: uid)
            await NotificationManager.shared.refreshUnreadCount(userId: uid)
        }
    }
    
    private func handleBackground() {
        Task {
            await NotificationManager.shared.unsubscribeFromRealtime()
        }
    }
    
    // MARK: - Deep Link
    
    private func handleDeepLink(_ link: DeepLink) {
        switch link {
        case .profile:              selectedTab = .profile
        case .assetDetail(_, _):    selectedTab = .profile
        case .portfolio:            selectedTab = .portfolio
        case .watchlist:            selectedTab = .watchlist
        case .market:               selectedTab = .discover
        case .discover:             selectedTab = .discover
        case .security:             selectedTab = .discover
        }
        
        NotificationCenter.default.post(name: .deepLinkReceived, object: link)
    }
}

extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}

//
//  NotificationsView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI
import Factory

struct NotificationsView: View {
    
    private var appState = Container.shared.appState()
    @State private var vm = NotificationsViewModel()
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Group {
            if vm.isLoading && vm.notifications.isEmpty {
                LoadingView()
            } else if vm.notifications.isEmpty {
                EmptyStateView(
                    icon: "bell",
                    title: String.localized("notifications.empty.title"),
                    message: String.localized("notifications.empty.message")
                )
            } else {
                notificationList
            }
        }
        .background(themeManager.theme.background)
        .navigationTitle(String.localized("notifications.nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .onDisappear {
            Task { await vm.unsubscribeFromRealtime() }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.unreadCount > 0 {
                    Button(String.localized("notifications.action.mark_all_read")) {
                        guard let uid = appState.currentUser?.id else { return }
                        Task { await vm.markAllAsRead(userId: uid) }
                    }
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 12, weight: .medium))
                }
            }
        }
        .task {
            guard let uid = appState.currentUser?.id else { return }
            await vm.load(userId: uid)
        }
    }
    
    // MARK: - Bildirim Listesi
    
    private var notificationList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.notifications) { notification in
                    Button {
                        handleNotificationTap(notification)
                    } label: {
                        NotificationRow(notification: notification)
                    }
                    .buttonStyle(.plain)
                    
                    if notification.id != vm.notifications.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .refreshable {
            guard let uid = appState.currentUser?.id else { return }
            await vm.load(userId: uid)
        }
    }
    
    // MARK: - Bildirime Tıklama
    
    private func handleNotificationTap(_ notification: AppNotification) {
        guard let uid = appState.currentUser?.id else { return }
        
        Task { await vm.markAsRead(id: notification.id, userId: uid) }
        
        if let assetId = notification.data?.assetId,
           let assetType = notification.data?.assetType {
            NotificationManager.shared.pendingDeepLink = .assetDetail(
                id: assetId,
                assetType: assetType
            )
        }
    }
}

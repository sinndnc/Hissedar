//
//  NotificationsView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI

struct NotificationsView: View {
    
    @Environment(AppState.self) var appState: AppState
    @State private var vm = NotificationsViewModel()
    
    var body: some View {
        Group {
            if vm.isLoading && vm.notifications.isEmpty {
                LoadingView()
            } else if vm.notifications.isEmpty {
                EmptyStateView(
                    icon: "bell",
                    title: "Bildirim yok",
                    message: "Kira gelirleri, token transferleri ve mülk güncellemeleri burada görünecek"
                )
            } else {
                notificationList
            }
        }
        .background(Color.hsBackground)
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onDisappear {
            Task { await vm.unsubscribeFromRealtime() }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.unreadCount > 0 {
                    Button("Tümünü Oku") {
                        guard let uid = appState.currentUser?.id else { return }
                        Task { await vm.markAllAsRead(userId: uid) }
                    }
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 12,weight: .medium))
                }
            }
            .sharedBackgroundVisibility(.hidden)
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
                        Divider().padding(.leading, 70)
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

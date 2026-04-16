// AppDelegate.swift

import UIKit
import Factory
import SwiftUI
internal import Auth
import Supabase

// MARK: - App Delegate
// HissedarApp'e @UIApplicationDelegateAdaptor ile bağlanır.

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    // MARK: - APNs Token Alındı
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            guard let session = try? await Container.shared.supabaseClient.resolve().auth.session else {
                return
            }
            let userId = session.user.id.uuidString
            await NotificationManager.shared.registerDeviceToken(deviceToken, userId: userId)
            // Token kaydedilince unread sayısını da çek
            await NotificationManager.shared.refreshUnreadCount(userId: userId)
        }
    }

    // MARK: - APNs Kayıt Hatası
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Simulator'da her zaman hata verir — gerçek cihazda test et
        print("APNs kayıt hatası: \(error.localizedDescription)")
    }

    // MARK: - Arka planda / ön planda bildirim geldi (silent push)
    // Supabase'den content-available: 1 ile tetiklenir.
    // Badge sayacını ve okunmamış sayısını günceller.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Task {
            guard let session = try? await Container.shared.supabaseClient.resolve().auth.session else {
                completionHandler(.noData)
                return
            }
            await NotificationManager.shared.refreshUnreadCount(userId: session.user.id.uuidString)
            completionHandler(.newData)
        }
    }
}

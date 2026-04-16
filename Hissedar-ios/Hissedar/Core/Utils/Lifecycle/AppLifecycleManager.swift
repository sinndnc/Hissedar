//
//  AppLifecycleManager.swift
//  Varlix
//
//  Created by Sinan Dinç on 1/16/26.
//
import Combine
import SwiftUI

// MARK: - App Lifecycle Manager
class AppLifecycleManager: ObservableObject {
    @Published var isAppActive = true
    @Published var requiresAuth = false
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func appWillResignActive() {
        isAppActive = false
    }
    
    @objc private func appDidEnterBackground() {
        // Uygulama arka plana gittiğinde kilitle
        requiresAuth = true
    }
    
    @objc private func appDidBecomeActive() {
        isAppActive = true
        // Uygulama ön plana geldiğinde kimlik doğrulama gerekli mi kontrol et
        if requiresAuth {
            // Kimlik doğrulama ekranı gösterilecek
        }
    }
    
    func authenticationCompleted() {
        requiresAuth = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

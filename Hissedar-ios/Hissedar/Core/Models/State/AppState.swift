//
//  HissedarApp.swift
//  Hissedar
//

import SwiftUI
import Factory
import Combine
internal import Auth

enum AuthState { case loading, authenticated, unauthenticated }

@MainActor
@Observable
class AppState {
    
    var currentUser: AppUser?
    var authState: AuthState = .loading
    private var initialSessionHandled = false
    
    private let authService = Container.shared.authService()
    private var authObserverTask: Task<Void, Never>?

    init() {
        startObservingAuth()
    }
    
    func startObservingAuth() {
        authObserverTask?.cancel() // prevent duplicate observers if called twice
        authObserverTask = Task {
            for await (event, session) in authService.observeAuthState() {
                await MainActor.run {
                    switch event {
                    case .initialSession:
                        initialSessionHandled = true  // 👈
                        if let session, !session.isExpired {
                            self.authState = .authenticated
                            Task { await self.loadProfile(userId: session.user.id.uuidString) }
                        } else {
                            self.authState = .unauthenticated
                        }
                        
                    case .tokenRefreshed:
                        if let session, !session.isExpired {
                            self.authState = .authenticated
                            Task { await self.loadProfile(userId: session.user.id.uuidString) }
                        } else {
                            // Only mark unauthenticated if initial check is done
                            if initialSessionHandled {  // 👈
                                self.authState = .unauthenticated
                            }
                        }
                        
                    case .signedIn:
                        self.authState = .authenticated
                        if let uid = session?.user.id.uuidString {
                            Task {
                                await self.loadProfile(userId: uid)
                                await NotificationManager.shared.subscribeToRealtime(userId: uid)
                            }
                        }
                        
                    case .signedOut, .userDeleted:
                        self.currentUser = nil
                        self.authState = .unauthenticated
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func loadProfile(userId: String) async {
        do {
            let profile = try await authService.fetchProfile(userId: userId)
            await MainActor.run { self.currentUser = profile }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                // ❌ Don't force unauthenticated on profile fetch failure
                // The auth session is still valid, just profile load failed
                // self.authState = .unauthenticated
            }
        }
    }
}

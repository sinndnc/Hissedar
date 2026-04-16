//
//  AuthRepository.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Supabase
import Foundation

protocol AuthRepositoryProtocol {
    var currentUserId: String? { get async }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, fullName: String) async throws
    func resetPassword(email: String) async throws
    func signOut() async throws
    func observeAuthState() -> AsyncStream<(AuthChangeEvent, Session?)>
}

final class AuthRepository: AuthRepositoryProtocol {
    
    @Injected(\.supabaseClient) private var client
    
    var currentUserId: String? {
        get async {
            try? await client.auth.session.user.id.uuidString
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    // FIX: fullName artık raw_user_meta_data'ya gönderiliyor
    // handle_new_user() trigger'ı bunu yakalayıp public.users'a yazacak
    func signUp(email: String, password: String, fullName: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(fullName)]
        )
    }
    
    // FIX: Boş implementasyon dolduruldu
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    // FIX: Boş implementasyon dolduruldu
    func signOut() async throws {
        try await client.auth.signOut()
    }

    func observeAuthState() -> AsyncStream<(AuthChangeEvent, Session?)> {
        AsyncStream { continuation in
            let task = Task {
                for await (event, session) in client.auth.authStateChanges {
                    continuation.yield((event, session))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

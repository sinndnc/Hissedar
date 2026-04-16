//
//  AuthServiceProtocol.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Foundation
internal import Auth

protocol AuthServiceProtocol {
    var currentUserId: String? { get async }
    func login(email: String, password: String) async throws
    func register(email: String, password: String, fullName: String) async throws
    func resetPassword(email: String) async throws
    func signOut() async throws
    func fetchProfile(userId: String) async throws -> AppUser
    func observeAuthState() -> AsyncStream<(AuthChangeEvent, Session?)>
}

final class AuthService: AuthServiceProtocol {
    
    @Injected(\.authRepository) private var authRepo
    @Injected(\.userRepository) private var userRepo
    
    var currentUserId: String? {
        get async { await authRepo.currentUserId }
    }
    
    func login(email: String, password: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !password.isEmpty else { throw AuthError.emptyFields }
        guard Self.isValidEmail(trimmed) else { throw AuthError.invalidEmail }
        try await authRepo.signIn(email: trimmed, password: password)
    }
    
    func register(email: String, password: String, fullName: String) async throws {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { throw AuthError.emptyName }
        guard password.count >= 8 else { throw AuthError.weakPassword }
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else { throw AuthError.emptyFields }
        guard Self.isValidEmail(trimmedEmail) else { throw AuthError.invalidEmail }
        try await authRepo.signUp(email: trimmedEmail, password: password, fullName: trimmedName)
    }
    
    func resetPassword(email: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw AuthError.emptyFields }
        try await authRepo.resetPassword(email: trimmed)
    }
    
    func signOut() async throws {
        try await authRepo.signOut()
    }
    
    func fetchProfile(userId: String) async throws -> AppUser {
        try await userRepo.fetchProfile(userId: userId)
    }
    
    func observeAuthState() -> AsyncStream<(AuthChangeEvent, Session?)> {
        authRepo.observeAuthState()
    }
    
    private static func isValidEmail(_ e: String) -> Bool {
        e.range(of: #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#,
                options: .regularExpression) != nil
    }
}

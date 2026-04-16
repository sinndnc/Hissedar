//
//  AuthViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Combine
import SwiftUI
import Factory

@MainActor
final class AuthViewModel: ObservableObject {

    @Injected(\.authService) private var service

    @Published var email         = ""
    @Published var password      = ""
    @Published var fullName      = ""
    @Published var isLoading     = false
    @Published var errorMessage: String?
    @Published var isRegistering = false
    @Published var resetSent     = false

    func login() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        do {
            try await service.login(email: email, password: password)
        } catch {
            Logger.log("error: \(error)")
            errorMessage = AuthError.map(error).localizedDescription
        }
    }

    func register() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        do {
            try await service.register(
                email: email, password: password, fullName: fullName
            )
        } catch {
            errorMessage = AuthError.map(error).localizedDescription
        }
    }

    func resetPassword() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        do {
            try await service.resetPassword(email: email)
            resetSent = true
        } catch {
            errorMessage = AuthError.map(error).localizedDescription
        }
    }
}

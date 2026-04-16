//
//  BiometricManager.swift
//  Varlix
//
//  Created by Sinan Dinç on 1/13/26.
//
import LocalAuthentication
import Combine
import SwiftUI

class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authError: AuthError?
    
    private let context = LAContext()
    private let reason = "Uygulamaya erişmek için kimliğinizi doğrulayın"
    
    enum AuthError: LocalizedError {
        case biometricNotAvailable
        case biometricNotEnrolled
        case authenticationFailed
        case userCancel
        case passcodeNotSet
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .biometricNotAvailable:
                return "Bu cihazda biyometrik kimlik doğrulama desteklenmiyor"
            case .biometricNotEnrolled:
                return "Biyometrik kimlik doğrulama ayarlanmamış. Lütfen cihaz ayarlarından Face ID veya Touch ID'yi aktifleştirin"
            case .authenticationFailed:
                return "Kimlik doğrulama başarısız oldu"
            case .userCancel:
                return "Kimlik doğrulama iptal edildi"
            case .passcodeNotSet:
                return "Cihazınızda parola ayarlanmamış"
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }
    
    // Biyometrik kimlik doğrulama türünü kontrol et
    var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }
    
    var biometricTypeString: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Biyometrik kimlik doğrulama"
        @unknown default:
            return "Biyometrik kimlik doğrulama"
        }
    }
    
    // Biyometrik kimlik doğrulamanın kullanılabilir olup olmadığını kontrol et
    func canUseBiometricAuth() -> (Bool, AuthError?) {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            switch error.code {
            case LAError.biometryNotAvailable.rawValue:
                return (false, .biometricNotAvailable)
            case LAError.biometryNotEnrolled.rawValue:
                return (false, .biometricNotEnrolled)
            case LAError.passcodeNotSet.rawValue:
                return (false, .passcodeNotSet)
            default:
                return (false, .unknown(error))
            }
        }
        
        return (canEvaluate, nil)
    }
    
    // Kimlik doğrulama işlemini başlat
    func authenticate(completion: @escaping (Bool, AuthError?) -> Void) {
        let (canUse, error) = canUseBiometricAuth()
        
        guard canUse else {
            DispatchQueue.main.async {
                self.authError = error
                self.isAuthenticated = false
            }
            completion(false, error)
            return
        }
        
        // Her kimlik doğrulamada yeni context kullan
        let newContext = LAContext()
        newContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.authError = nil
                    completion(true, nil)
                } else {
                    let authError = self.handleAuthError(error)
                    self.isAuthenticated = false
                    self.authError = authError
                    completion(false, authError)
                }
            }
        }
    }
    
    // Async/await versiyonu
    @MainActor
    func authenticateAsync() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            authenticate { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // Hata işleme
    private func handleAuthError(_ error: Error?) -> AuthError {
        guard let error = error as? LAError else {
            return .unknown(error ?? NSError())
        }
        
        switch error.code {
        case .userCancel, .userFallback, .appCancel, .systemCancel:
            return .userCancel
        case .authenticationFailed:
            return .authenticationFailed
        case .biometryNotAvailable:
            return .biometricNotAvailable
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .unknown(error)
        }
    }
    
    // Çıkış yap veya kilitle
    func lock() {
        isAuthenticated = false
        authError = nil
    }
}

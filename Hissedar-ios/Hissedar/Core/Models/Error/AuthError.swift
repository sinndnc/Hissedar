//
//  AuthError.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Foundation

enum AuthError: LocalizedError {
    case emptyFields
    case invalidEmail
    case emptyName
    case weakPassword
    case invalidCredentials
    case alreadyRegistered
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyFields:          return "Tüm alanları doldurun"
        case .invalidEmail:         return "Geçerli e-posta girin"
        case .emptyName:            return "Ad soyad gerekli"
        case .weakPassword:         return "Şifre en az 8 karakter olmalı"
        case .invalidCredentials:   return "E-posta veya şifre hatalı"
        case .alreadyRegistered:    return "Bu e-posta zaten kayıtlı"
        case .networkError:         return "İnternet bağlantısı yok"
        case .unknown:              return "Bir hata oluştu, tekrar deneyin"
        }
    }

    static func map(_ error: Error) -> AuthError {
        if let authError = error as? AuthError { return authError }
        let m = error.localizedDescription.lowercased()
        if m.contains("invalid login") || m.contains("invalid credentials") {
            return .invalidCredentials
        }
        if m.contains("already registered") || m.contains("already exists") {
            return .alreadyRegistered
        }
        if m.contains("network") || m.contains("offline") {
            return .networkError
        }
        return .unknown
    }
}

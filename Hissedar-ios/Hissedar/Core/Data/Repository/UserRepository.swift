//
//  UserRepository.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Supabase
import Foundation

// ✅ Sorunsuz — tablo adı ve kolonlar yeni şemayla uyumlu
protocol UserRepositoryProtocol {
    func fetchProfile(userId: String) async throws -> AppUser
    func updateProfile(_ user: AppUser) async throws
}

final class UserRepository: UserRepositoryProtocol {

    @Injected(\.supabaseClient) private var client

    func fetchProfile(userId: String) async throws -> AppUser {
        try await client
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }

    func updateProfile(_ user: AppUser) async throws {
        try await client
            .from("users")
            .update(user)
            .eq("id", value: user.id)
            .execute()
    }
}

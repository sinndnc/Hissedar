//
//  RentServiceProtocol.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//
//  Kira geçmişi ve dağıtım verilerini Supabase'den çeker.
//

import Factory
import Supabase
import Foundation

protocol RentServiceProtocol {
    func fetchRentHistory(userId: String) async throws -> [RentHistory]
    func fetchRentHistoryForAsset(userId: String, assetId: String) async throws -> [RentHistory]
    func fetchTotalRentEarned(userId: String) async throws -> Decimal
}

final class RentService: RentServiceProtocol {
    
    @Injected(\.supabaseClient) private var client
    
    /// Kullanıcının tüm kira geçmişi (tüm varlıklar)
    func fetchRentHistory(userId: String) async throws -> [RentHistory] {
        try await client
            .from("user_rent_history")
            .select()
            .eq("user_id", value: userId)
            .order("paid_at", ascending: false)
            .execute()
            .value
    }
    
    /// Belirli bir varlık için kira geçmişi
    func fetchRentHistoryForAsset(userId: String, assetId: String) async throws -> [RentHistory] {
        try await client
            .from("user_rent_history")
            .select()
            .eq("user_id", value: userId)
            .eq("asset_id", value: assetId)
            .order("paid_at", ascending: false)
            .execute()
            .value
    }
    
    /// Toplam kazanılan kira (hızlı sorgu)
    func fetchTotalRentEarned(userId: String) async throws -> Decimal {
        let history = try await fetchRentHistory(userId: userId)
        return history.reduce(Decimal.zero) { $0 + $1.rentAmount }
    }
}

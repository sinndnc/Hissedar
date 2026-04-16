//
//  ExchangeRepositoryProtocol.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/9/26.
//

import Factory
import Supabase
import Foundation

protocol ExchangeRepositoryProtocol {
    func buyHSR(userId: String, tryAmount: Decimal, feePercent: Decimal) async throws -> ExchangeResult
    func sellHSR(userId: String, hsrAmount: Decimal, feePercent: Decimal) async throws -> ExchangeResult
    func fetchExchangeHistory(userId: String) async throws -> [TokenExchange]
}

struct ExchangeResult: Codable {
    let success: Bool
    let exchangeId: String
    let trySpent: Decimal?
    let hsrReceived: Decimal?
    let hsrSpent: Decimal?
    let tryReceived: Decimal?
    let fee: Decimal
    let exchangeRate: Decimal
    let newTryBalance: Decimal
    let newHsrBalance: Decimal

    enum CodingKeys: String, CodingKey {
        case success, fee
        case exchangeId     = "exchange_id"
        case trySpent       = "try_spent"
        case hsrReceived    = "hsr_received"
        case hsrSpent       = "hsr_spent"
        case tryReceived    = "try_received"
        case exchangeRate   = "exchange_rate"
        case newTryBalance  = "new_try_balance"
        case newHsrBalance  = "new_hsr_balance"
    }
}

final class ExchangeRepository: ExchangeRepositoryProtocol {

    @Injected(\.supabaseClient) private var client

    func buyHSR(userId: String, tryAmount: Decimal, feePercent: Decimal = 0) async throws -> ExchangeResult {
        let response = try await client
            .rpc("buy_hsr", params: [
                "p_user_id": AnyJSON.string(userId),
                "p_try_amount": AnyJSON.double(NSDecimalNumber(decimal: tryAmount).doubleValue),
                "p_fee_percent": AnyJSON.double(NSDecimalNumber(decimal: feePercent).doubleValue)
            ])
            .execute()

        return try decodeRPCResult(response.data)
    }

    func sellHSR(userId: String, hsrAmount: Decimal, feePercent: Decimal = 0) async throws -> ExchangeResult {
        let response = try await client
            .rpc("sell_hsr", params: [
                "p_user_id": AnyJSON.string(userId),
                "p_hsr_amount": AnyJSON.double(NSDecimalNumber(decimal: hsrAmount).doubleValue),
                "p_fee_percent": AnyJSON.double(NSDecimalNumber(decimal: feePercent).doubleValue)
            ])
            .execute()

        return try decodeRPCResult(response.data)
    }

    func fetchExchangeHistory(userId: String) async throws -> [TokenExchange] {
        try await client
            .from("token_exchanges")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Private

    private func decodeRPCResult(_ data: Data) throws -> ExchangeResult {
        if let result = try? JSONDecoder().decode(ExchangeResult.self, from: data) {
            return result
        }
        if let array = try? JSONDecoder().decode([ExchangeResult].self, from: data),
           let first = array.first {
            return first
        }
        let raw = String(data: data, encoding: .utf8) ?? "nil"
        throw TradeError.serverError("Exchange yanıtı parse edilemedi: \(raw)")
    }
}

//
//  TradeError.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Foundation

enum TradeError: LocalizedError {
    case insufficientTokens
    case insufficientBalance
    case invalidAmount
    case invalidPrice
    case orderNotFound
    case cannotBuyOwnOrder
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .insufficientTokens:  return "Yeterli token yok"
        case .insufficientBalance: return "Yetersiz bakiye"
        case .invalidAmount:       return "Geçersiz miktar"
        case .invalidPrice:        return "Geçersiz fiyat"
        case .orderNotFound:       return "Emir bulunamadı"
        case .cannotBuyOwnOrder:   return "Kendi emirinizi alamazsınız"
        case .serverError(let msg): return msg
        }
    }
}

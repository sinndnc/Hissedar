//
//  BigInt+Extenisons.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/30/26.
//

import BigInt
import Foundation

extension BigInt {
    
    /// Wei'den Ether'e çevirme (1 ETH = 10^18 Wei)
    /// - Parameter decimals: Ondalık basamak sayısı
    /// - Returns: Formatlanmış Ether string'i
    func toEther(decimals: Int = 4) -> String {
        let divisor = BigInt(10).power(18)
        let etherWhole = self / divisor
        let remainder = self % divisor
        
        // Ondalık kısmı hesapla
        let remainderString = String(remainder)
        let paddedRemainder = String(repeating: "0", count: 18 - remainderString.count) + remainderString
        
        // İstenen ondalık basamak sayısına göre yuvarla
        let decimalPart = String(paddedRemainder.prefix(decimals))
        
        // Sondaki sıfırları temizle
        let trimmedDecimal = decimalPart.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        
        if trimmedDecimal.isEmpty {
            return String(etherWhole)
        } else {
            return "\(etherWhole).\(trimmedDecimal)"
        }
    }
    
    /// Wei'den Gwei'ye çevirme (1 Gwei = 10^9 Wei)
    /// - Parameter decimals: Ondalık basamak sayısı
    /// - Returns: Formatlanmış Gwei string'i
    func toGwei(decimals: Int = 2) -> String {
        let divisor = BigInt(10).power(9)
        let gweiWhole = self / divisor
        let remainder = self % divisor
        
        let remainderString = String(remainder)
        let paddedRemainder = String(repeating: "0", count: 9 - remainderString.count) + remainderString
        
        let decimalPart = String(paddedRemainder.prefix(decimals))
        let trimmedDecimal = decimalPart.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        
        if trimmedDecimal.isEmpty {
            return String(gweiWhole)
        } else {
            return "\(gweiWhole).\(trimmedDecimal)"
        }
    }
    
    /// Formatlanmış gösterim (binlik ayırıcı ile)
    /// - Parameter separator: Binlik ayırıcı (varsayılan: ",")
    /// - Returns: Formatlanmış string
    func formatted(separator: String = ",") -> String {
        let str = String(self)
        var result = ""
        var count = 0
        
        for char in str.reversed() {
            if count == 3 {
                result.insert(contentsOf: separator, at: result.startIndex)
                count = 0
            }
            result.insert(char, at: result.startIndex)
            count += 1
        }
        
        return result
    }
}

//
//  BigUInt+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/30/26.
//

import Foundation
import BigInt

extension BigUInt{
    
    static func fromHex(_ hex: String) -> BigUInt? {
        let cleanHex = hex.replacingOccurrences(of: "0x", with: "")
        return BigUInt(cleanHex, radix: 16)
    }
    
    func scaleDecimals(from fromDecimals: Int, to toDecimals: Int) -> BigUInt {
        if fromDecimals == toDecimals {
            return self
        } else if fromDecimals > toDecimals {
            let divisor = BigUInt(10).power(fromDecimals - toDecimals)
            return self / divisor
        } else {
            let multiplier = BigUInt(10).power(toDecimals - fromDecimals)
            return self * multiplier
        }
    }
    
    func toReadableString(decimals: Int) -> String {
        let divisor = BigUInt(10).power(decimals)
        let wholePart = self / divisor
        let fractionPart = self % divisor
        
        let fractionString = String(fractionPart)
        let paddedFraction = String(repeating: "0", count: decimals - fractionString.count) + fractionString
        let trimmedFraction = paddedFraction.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        
        if trimmedFraction.isEmpty {
            return "\(wholePart)"
        } else {
            return "\(wholePart).\(trimmedFraction)"
        }
    }
}

//
//  Data+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/29/26.
//

import Foundation

extension Data {
    
    /// Data'yı hex string'e çevirir (0x prefix ile)
    /// - Parameter includePrefix: "0x" prefix'i eklensin mi (varsayılan: true)
    /// - Returns: Hex string
    func toHexString(includePrefix: Bool = true) -> String {
        let hexString = self.map { String(format: "%02x", $0) }.joined()
        return includePrefix ? "0x" + hexString : hexString
    }
    
    /// Hex string'den Data oluşturur
    /// - Parameter hex: Hex string (0x ile veya olmadan)
    /// - Returns: Data veya nil
    static func fromHex(_ hex: String) -> Data? {
        let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        
        guard cleanHex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = cleanHex.startIndex
        
        while index < cleanHex.endIndex {
            let nextIndex = cleanHex.index(index, offsetBy: 2)
            let byteString = cleanHex[index..<nextIndex]
            
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            
            data.append(byte)
            index = nextIndex
        }
        
        return data
    }
    
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex
        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        self = data
    }
}

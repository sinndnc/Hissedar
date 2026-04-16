//
//  Logger.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/25/26.
//

import Foundation

struct Logger {
    static func log(_ message: String) {
        print("🔍 [LOG]: \(message)")
    }
}

extension Logger {
    enum Level {
        case info, warning, error, debug
        
        var prefix: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .debug: return "🔍"
            }
        }
    }
    
    static func log(_ message: String, level: Level = .debug) {
        #if DEBUG
        print("\(level.prefix) [\(level)] \(message)")
        #endif
    }
}

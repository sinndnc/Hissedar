//
//  Bundle+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/29/26.
//

import Foundation

extension Bundle {
    var infuraKey: String {
        object(forInfoDictionaryKey: "INFURA_API_KEY") as? String ?? ""
    }
    var alchemyKey: String {
        object(forInfoDictionaryKey: "ALCHEMY_API_KEY") as? String ?? ""
    }
    var etherscanKey: String {
        object(forInfoDictionaryKey: "ETHERCSAN_API_KEY") as? String ?? ""
    }
    var supabaseURL: String {
        object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
    }
    var supabaseAnonKey: String {
        object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }
}


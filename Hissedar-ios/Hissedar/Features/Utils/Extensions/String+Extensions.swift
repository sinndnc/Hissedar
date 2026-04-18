//
//  String+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/17/26.
//

import Foundation

extension String {
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: LanguageManager.shared.bundle, comment: "")
    }
}

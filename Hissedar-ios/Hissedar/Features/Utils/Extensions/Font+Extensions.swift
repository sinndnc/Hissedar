//
//  Font+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

extension Font {
    static let hDisplay     = Font.system(size: 32, weight: .bold,     design: .rounded)
    static let hLargeTitle  = Font.system(size: 26, weight: .bold,     design: .rounded)
    static let hTitle       = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let hTitle2      = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let hHeadline    = Font.system(size: 15, weight: .semibold, design: .default)
    static let hBody        = Font.system(size: 14, weight: .regular,  design: .default)
    static let hBodyMedium  = Font.system(size: 14, weight: .medium,   design: .default)
    static let hCaption     = Font.system(size: 12, weight: .regular,  design: .default)
    static let hCaptionMed  = Font.system(size: 12, weight: .semibold, design: .default)
    static let hLabel       = Font.system(size: 11, weight: .semibold, design: .default)
    static let hMono        = Font.system(size: 13, weight: .regular,  design: .monospaced)
}

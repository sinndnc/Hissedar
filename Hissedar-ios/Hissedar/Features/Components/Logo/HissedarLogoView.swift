//
//  HissedarLogo.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct HissedarLogoView: View {
    var size: CGFloat   = 40
    var foreground: Color = .hWhite

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

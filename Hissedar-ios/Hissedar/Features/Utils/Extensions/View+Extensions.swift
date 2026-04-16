//
//  View+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

//
//  HTextField.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct HTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.hLabel).foregroundStyle(Color.hsTextPrimary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                        .autocorrectionDisabled()
                }
            }
            .font(.hBody)
            .foregroundStyle(Color.hsTextPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.hsBackground)
            .clipShape(RoundedRectangle(cornerRadius: .hRadiusSm))
            .overlay(
                RoundedRectangle(cornerRadius: .hRadiusSm)
                    .strokeBorder(
                        focused ? Color.hJade : Color.hsBorder,
                        lineWidth: focused ? 1.5 : 1
                    )
                    .animation(.easeInOut(duration: 0.15), value: focused)
            )
            .focused($focused)
        }
    }
}

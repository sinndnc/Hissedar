//
//  EmptyStateView.swift
//  Hissedar
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.hsBackground)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.hsBorder, lineWidth: 0.5)
                    )
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.hsTextPrimary.opacity(0.7))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.hTitle2)
                    .foregroundStyle(Color.hsTextPrimary)
                Text(message)
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                        Text(actionTitle)
                            .font(.hBodyMedium)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(Color.hEmerald)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

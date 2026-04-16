// MARK: - TrendingCard.swift
// Hissedar — Trend Kart Bileşeni (Yatay Kaydırma)

import SwiftUI

struct TrendingCard: View {
    let accentColor: Color
    let badge: String?
    let title: String
    let subtitle: String
    let sparklineData: [Double]
    let isPositive: Bool
    let price: String
    let change: String
    let imageUrl: String

    init(
        accentColor: Color,
        badge: String? = nil,
        title: String,
        subtitle: String,
        sparklineData: [Double],
        isPositive: Bool,
        price: String,
        change: String,
        imageUrl: String
    ) {
        self.accentColor = accentColor
        self.badge = badge
        self.title = title
        self.subtitle = subtitle
        self.sparklineData = sparklineData
        self.isPositive = isPositive
        self.price = price
        self.change = change
        self.imageUrl = imageUrl
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // MARK: - Full-bleed image
                if let imageURL = URL(string: imageUrl) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        default:
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .background(Color.hsBackgroundTertiary)
                        }
                    }
                } else {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .background(Color.hsBackgroundTertiary)
                }
                
                // MARK: - Top accent bar
                VStack {
                    accentColor
                        .frame(height: 3)
                        .mask(
                            LinearGradient(
                                colors: [accentColor, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }

                // MARK: - Top-trailing badge
                if let badge {
                    VStack {
                        HStack {
                            Spacer()
                            BadgeLabel(badge: badge)
                                .padding(10)
                        }
                        Spacer()
                    }
                }

                // MARK: - Gradient overlay + info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(price)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)

                            Text(change)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(isPositive ? Color.hsSuccess : Color.hsError)
                                .background(isPositive ? Color.hsSuccess.opacity(0.15) : Color.hsError.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    ProgressView(value: Double.random(in: 0.0...0.9))
                        .frame(height: 3)
                        .progressViewStyle(.linear)
                        .tint(Color.hsPurple400)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(0.3),
                            .black.opacity(0.7),
                            .black.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.hsBorder, lineWidth: 1)
            )
        }
    }
}


// MARK: - Badge Label
struct BadgeLabel: View {
    let badge: String

    var body: some View {
        Text(badge)
            .font(.system(size: 10, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.hsTextPrimary)
            .foregroundColor(Color.hsBackgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}


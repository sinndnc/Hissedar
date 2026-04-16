//
//  AssetDetailView.swift
//  Hissedar
//
//
// MARK: - TrendingCard.swift
// Hissedar — Trend Kart Bileşeni (Yatay Kaydırma)

import SwiftUI

struct TrendingCard: View {
    let item: AssetItem

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // MARK: - Full-bleed image
                if let urlString = item.imageUrl, let imageURL = URL(string: urlString) {
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
                    Color.hsBackgroundTertiary
                        .frame(height: 3)
                        .mask(
                            LinearGradient(
                                colors: [Color.hsBackgroundTertiary, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }

                // MARK: - Top-trailing badge
                if let badge = item.badge {
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
                            Text(item.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(item.trendingSubtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(item.formattedPrice)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)

                            Text(item.formattedChange)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(item.isPositive ? Color.hsSuccess : Color.hsError)
                                .background(
                                    item.isPositive
                                        ? Color.hsSuccess.opacity(0.15)
                                        : Color.hsError.opacity(0.15)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    // Fonlama ilerlemesi (soldTokens / totalTokens)
                    ProgressView(value: item.fundingPercent / 100)
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


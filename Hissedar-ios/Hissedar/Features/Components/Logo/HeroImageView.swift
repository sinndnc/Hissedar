//
//  HeroImageView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct HeroImageView: View {
    let imageUrl: String?
    let fallbackIcon: String
    let height: CGFloat

    init(imageUrl: String?, fallbackIcon: String = "photo", height: CGFloat = 200) {
        self.imageUrl = imageUrl
        self.fallbackIcon = fallbackIcon
        self.height = height
    }

    var body: some View {
        ZStack {
            if let urlStr = imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                            .clipped()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }

            // Gradient overlay
            LinearGradient(
                colors: [
                    .clear,
                    Color.hsBackground.opacity(0.3),
                    Color.hsBackground.opacity(0.7),
                    Color.hsBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }

    private var placeholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.hsPurple900.opacity(0.4), Color.hsBackgroundSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                Image(systemName: fallbackIcon)
                    .font(.system(size: 52))
                    .foregroundStyle(Color.hsPurple400.opacity(0.5))
            }
    }
}

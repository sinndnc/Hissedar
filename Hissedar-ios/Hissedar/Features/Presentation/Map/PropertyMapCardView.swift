//
//  PropertyMapCardView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct PropertyMapCardView: View {
    
    let item: AssetItem
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.hsTextSecondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
            
            HStack(alignment: .top, spacing: 14) {
                // Thumbnail
                AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Color.hsBackgroundSecondary
                            .overlay {
                                Image(systemName: item.icon)
                                    .foregroundStyle(Color.hsTextSecondary)
                            }
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .lineLimit(1)
                    
                    if let city = item.propertyCity {
                        Label(city, systemImage: "mappin")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Token Fiyatı")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.hsTextSecondary)
                            Text(item.formattedPrice)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.hsTextPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Getiri")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.hsTextSecondary)
                            Text("%\(String(format: "%.1f", item.annualYieldPercent))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.hsAccent)
                        }
                        
                        Spacer()
                    }
                    
                    // Funding bar
                    VStack(alignment: .leading, spacing: 3) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.hsBackgroundSecondary)
                                    .frame(height: 5)
                                Capsule()
                                    .fill(Color.hsAccent)
                                    .frame(width: geo.size.width * min(item.fundingPercent / 100, 1.0), height: 5)
                            }
                        }
                        .frame(height: 5)
                        
                        Text("%\(String(format: "%.0f", item.fundingPercent)) fonlandı")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                }
            }
            .padding(16)
            
            // Action button
            NavigationLink {
                AssetDetailView(assetId: item.id)
            } label: {
                Text("Detayları Gör")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .foregroundStyle(Color.hsBackground)
                    .background(Color.hsAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.hsBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: -4)
    }
}

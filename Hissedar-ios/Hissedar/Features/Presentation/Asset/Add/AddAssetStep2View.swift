//
//  AddAssetStep2View.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct AddAssetStep2View: View {
    
    @Bindable var viewModel: AddAssetViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Varlık Türü Seçin")
                        .font(.system(size: 22, weight: .bold))
                    
                    Text("Tokenize etmek istediğiniz varlık türünü belirleyin")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                
                // Type Cards
                VStack(spacing: 12) {
                    ForEach(AssetTypeOption.allCases) { type in
                        assetTypeCard(type)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Asset Type Card
    
    private func assetTypeCard(_ type: AssetTypeOption) -> some View {
        let isSelected = viewModel.selectedAssetType == type
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                viewModel.selectedAssetType = type
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconColor(for: type).opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(iconColor(for: type))
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(type.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.accentColor.opacity(0.06) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func iconColor(for type: AssetTypeOption) -> Color {
        switch type {
        case .property: return .blue
        case .art: return .purple
        case .nft: return .orange
        }
    }
}

#Preview {
    AddAssetStep2View(viewModel: AddAssetViewModel())
}

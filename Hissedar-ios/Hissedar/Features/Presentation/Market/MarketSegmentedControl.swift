// MARK: - MarketSegmentedControl.swift
// Hissedar — Özel Segmented Tab Bar

import SwiftUI

struct MarketSegmentedControl: View {
    
    @Binding var selected: AssetFilter
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(AssetFilter.allCases,id: \.self) { tab in
                let isActive = selected == tab
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selected = tab
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(tab.label)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(isActive ? Color.hsTextPrimary : Color.hsTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isActive {
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.hsBackgroundTertiary)
                                .shadow(color: Color.hsBackgroundSecondary.opacity(0.3),radius: 8,y: 2)
                                .matchedGeometryEffect(id: "activeTab", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}



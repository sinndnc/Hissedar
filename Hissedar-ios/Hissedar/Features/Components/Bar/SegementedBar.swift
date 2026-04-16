//
//  SegementedBar.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct SegmentedBar<T: Hashable & CaseIterable>: View {
    let items: [T]
    let icon: (T) -> String
    let label: (T) -> String
    @Binding var selected: T
    var animation: Animation = .easeInOut(duration: 0.25)
    
    @Namespace private var segmentNS
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let isSelected = selected == item
                
                VStack{
                    Divider()
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(animation) { selected = item }
                    } label: {
                        Text(label(item))
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(isSelected ? Color.hsPurple600 : Color.hsTextSecondary)
                    
                    Rectangle()
                        .frame(height: isSelected ? 2 : 0.5)
                        .foregroundStyle(
                            isSelected ? Color.hsPurple600 : Color.gray.opacity(0.2)
                        )
                }
            }
        }
    }
}

//
//  FilterBar.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct FilterBar<T: Hashable & CaseIterable>: View {
    let items: [T]
    let icon: (T) -> String
    let label: (T) -> String
    @Binding var selected: T
    var animation: Animation = .easeInOut(duration: 0.2)
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    FilterPill(
                        icon: icon(item),
                        label: label(item),
                        isSelected: selected == item
                    ) {
                        withAnimation(animation) { selected = item }
                    }
                }
            }
        }
    }
}

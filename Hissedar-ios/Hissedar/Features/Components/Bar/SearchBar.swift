//
//  SearchBar.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/26/26.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    
    var body: some View{
        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.hsTextPrimary.opacity(0.6))
            
            TextField("", text: $searchText, prompt:
                        Text("Varlık, token veya koleksiyon ara…")
                .foregroundColor(.hsTextPrimary.opacity(0.5))
            )
            .font(.system(size: 15))
            .foregroundColor(.hsLavenderLight)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.hsPurple400.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    searchText.isEmpty
                    ? Color.hsBorder
                    : Color.hsSuccess.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

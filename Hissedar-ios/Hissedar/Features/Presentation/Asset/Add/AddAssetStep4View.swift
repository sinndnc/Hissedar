//
//  AddAssetStep4View.swift
//  Hissedar
//

import SwiftUI

struct AddAssetStep4View: View {
    
    @Bindable var viewModel: AddAssetViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.accentColor)
                    Text(String.localized("wizard.step.3.title"))
                        .font(.system(size: 22, weight: .bold))
                    Text(String.localized("wizard.step.3.subtitle"))
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                
                // Image Preview
                if !viewModel.imageUrl.isEmpty {
                    AsyncImage(url: URL(string: viewModel.imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure: imagePlaceholder
                        case .empty: ProgressView().frame(height: 200)
                        @unknown default: imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
                
                // Data Sections
                previewSection(String.localized("wizard.section.general"), icon: "doc.text.fill") {
                    previewRow(String.localized("wizard.field.title.label"), viewModel.title)
                    previewRow(String.localized("wizard.field.description.label"), viewModel.description)
                }
                
                previewSection(String.localized("wizard.section.financial"), icon: "turkishlirasign.circle.fill") {
                    previewRow(String.localized("wizard.field.total_value.label"), "₺\(viewModel.totalValue)")
                    previewRow(String.localized("wizard.field.token_price.label"), "₺\(viewModel.tokenPrice)")
                    previewRow(String.localized("wizard.field.total_tokens.label"), viewModel.totalTokens)
                }
                
                // Disclaimer
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle.fill").foregroundStyle(.blue).font(.system(size: 16))
                    Text(String.localized("wizard.preview.disclaimer"))
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .padding(14).background(Color.blue.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    private func previewSection(_ title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).foregroundStyle(Color.accentColor)
                Text(title).font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(String.localized("common.edit")) { viewModel.goToStep(.generalInfo) }
                    .font(.system(size: 12)).foregroundStyle(Color.accentColor)
            }
            Divider()
            content()
        }
        .padding(16).background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func previewRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).font(.system(size: 14)).foregroundStyle(.secondary).frame(width: 110, alignment: .leading)
            Text(value.isEmpty ? "—" : value).font(.system(size: 14, weight: .medium)).foregroundStyle(.primary)
            Spacer()
        }
    }
    
    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)).frame(height: 200)
            .overlay { Image(systemName: "photo").foregroundStyle(.tertiary) }
    }
}

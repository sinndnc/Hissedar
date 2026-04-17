//
//  AddAssetStep1View.swift
//  Hissedar
//

import SwiftUI

struct AddAssetStep1View: View {
    
    @Bindable var viewModel: AddAssetViewModel
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case title, description, totalValue, tokenPrice, totalTokens, annualYield, monthlyRent, imageUrl, badge
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                sectionHeader(
                    icon: "doc.text.fill",
                    title: String.localized("wizard.step.0.title"),
                    subtitle: String.localized("wizard.step.0.subtitle")
                )
                
                // Başlık & Açıklama
                VStack(spacing: 16) {
                    FormTextField(
                        label: String.localized("wizard.field.title.label"),
                        placeholder: String.localized("wizard.field.title.placeholder"),
                        text: $viewModel.title,
                        icon: "textformat"
                    )
                    .focused($focusedField, equals: .title)
                    
                    FormTextEditor(
                        label: String.localized("wizard.field.description.label"),
                        placeholder: String.localized("wizard.field.description.placeholder"),
                        text: $viewModel.description
                    )
                }
                .formSection()
                
                // Finansal Bilgiler
                VStack(spacing: 16) {
                    sectionLabel(String.localized("wizard.section.financial"))
                    
                    FormTextField(
                        label: String.localized("wizard.field.total_value.label"),
                        placeholder: "2.500.000",
                        text: $viewModel.totalValue,
                        icon: "turkishlirasign.circle.fill",
                        keyboardType: .numberPad
                    )
                    .focused($focusedField, equals: .totalValue)
                    
                    HStack(spacing: 12) {
                        FormTextField(
                            label: String.localized("wizard.field.token_price.label"),
                            placeholder: "2.500",
                            text: $viewModel.tokenPrice,
                            icon: "tag.fill",
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .tokenPrice)
                        
                        FormTextField(
                            label: String.localized("wizard.field.total_tokens.label"),
                            placeholder: "1.000",
                            text: $viewModel.totalTokens,
                            icon: "number",
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .totalTokens)
                    }
                    
                    // Auto-calculated info
                    if !viewModel.totalValue.isEmpty && !viewModel.totalTokens.isEmpty {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.blue)
                            Text("\(String.localized("wizard.calc.token_price")): \(viewModel.calculatedTokenPrice)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .formSection()
                
                // Getiri Bilgileri
                VStack(spacing: 16) {
                    sectionLabel(String.localized("wizard.section.yield"))
                    
                    HStack(spacing: 12) {
                        FormTextField(
                            label: String.localized("wizard.field.annual_yield.label"),
                            placeholder: "8.5",
                            text: $viewModel.annualYield,
                            icon: "chart.line.uptrend.xyaxis",
                            keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .annualYield)
                        
                        FormTextField(
                            label: String.localized("wizard.field.monthly_rent.label"),
                            placeholder: "12.500",
                            text: $viewModel.monthlyRent,
                            icon: "calendar.badge.clock",
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .monthlyRent)
                    }
                }
                .formSection()
                
                // Görsel & Badge
                VStack(spacing: 16) {
                    sectionLabel(String.localized("wizard.section.extra"))
                    
                    FormTextField(
                        label: String.localized("wizard.field.image_url.label"),
                        placeholder: "https://...",
                        text: $viewModel.imageUrl,
                        icon: "photo.fill",
                        keyboardType: .URL
                    )
                    .focused($focusedField, equals: .imageUrl)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    FormTextField(
                        label: String.localized("wizard.field.badge.label"),
                        placeholder: String.localized("wizard.field.badge.placeholder"),
                        text: $viewModel.badge,
                        icon: "star.fill"
                    )
                    .focused($focusedField, equals: .badge)
                }
                .formSection()
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(Color.accentColor)
            Text(title)
                .font(.system(size: 22, weight: .bold))
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

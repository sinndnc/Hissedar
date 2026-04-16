//
//  AddAssetStep1View.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
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
                    title: "Genel Bilgiler",
                    subtitle: "Varlığınızın temel bilgilerini girin"
                )
                
                // Başlık & Açıklama
                VStack(spacing: 16) {
                    FormTextField(
                        label: "Varlık Başlığı",
                        placeholder: "örn: Kadıköy Sahil Residence",
                        text: $viewModel.title,
                        icon: "textformat"
                    )
                    .focused($focusedField, equals: .title)
                    
                    FormTextEditor(
                        label: "Açıklama",
                        placeholder: "Varlık hakkında detaylı bilgi...",
                        text: $viewModel.description
                    )
                }
                .formSection()
                
                // Finansal Bilgiler
                VStack(spacing: 16) {
                    sectionLabel("Finansal Bilgiler")
                    
                    FormTextField(
                        label: "Toplam Değer (₺)",
                        placeholder: "2.500.000",
                        text: $viewModel.totalValue,
                        icon: "turkishlirasign.circle.fill",
                        keyboardType: .numberPad
                    )
                    .focused($focusedField, equals: .totalValue)
                    
                    HStack(spacing: 12) {
                        FormTextField(
                            label: "Token Fiyatı (₺)",
                            placeholder: "2.500",
                            text: $viewModel.tokenPrice,
                            icon: "tag.fill",
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .tokenPrice)
                        
                        FormTextField(
                            label: "Toplam Token",
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
                            Text("Hesaplanan token fiyatı: \(viewModel.calculatedTokenPrice)")
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
                    sectionLabel("Getiri Bilgileri")
                    
                    HStack(spacing: 12) {
                        FormTextField(
                            label: "Yıllık Getiri (%)",
                            placeholder: "8.5",
                            text: $viewModel.annualYield,
                            icon: "chart.line.uptrend.xyaxis",
                            keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .annualYield)
                        
                        FormTextField(
                            label: "Aylık Kira (₺)",
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
                    sectionLabel("Ek Bilgiler")
                    
                    FormTextField(
                        label: "Görsel URL",
                        placeholder: "https://...",
                        text: $viewModel.imageUrl,
                        icon: "photo.fill",
                        keyboardType: .URL
                    )
                    .focused($focusedField, equals: .imageUrl)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    FormTextField(
                        label: "Rozet (Opsiyonel)",
                        placeholder: "örn: Popüler, Yeni, Fırsat",
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
    
    // MARK: - Helpers
    
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

// MARK: - Reusable Form Components

struct FormTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                        .frame(width: 20)
                }
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct FormTextEditor: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 100, maxHeight: 160)
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Section Modifier

extension View {
    func formSection() -> some View {
        self
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AddAssetStep1View(viewModel: AddAssetViewModel())
}

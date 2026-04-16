//
//  AddAssetStep4View.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
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
                    
                    Text("Önizleme")
                        .font(.system(size: 22, weight: .bold))
                    
                    Text("Bilgileri kontrol edin ve ilanı yayınlayın")
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
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            imagePlaceholder
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
                
                // General Info Section
                previewSection("Genel Bilgiler", icon: "doc.text.fill") {
                    previewRow("Başlık", viewModel.title)
                    previewRow("Açıklama", viewModel.description)
                    
                    if !viewModel.badge.isEmpty {
                        previewRow("Rozet", viewModel.badge)
                    }
                }
                
                // Financial Info Section
                previewSection("Finansal Bilgiler", icon: "turkishlirasign.circle.fill") {
                    previewRow("Toplam Değer", "₺\(viewModel.totalValue)")
                    previewRow("Token Fiyatı", "₺\(viewModel.tokenPrice)")
                    previewRow("Toplam Token", viewModel.totalTokens)
                    previewRow("Yıllık Getiri", "%\(viewModel.annualYield)")
                    
                    if !viewModel.monthlyRent.isEmpty {
                        previewRow("Aylık Kira", "₺\(viewModel.monthlyRent)")
                    }
                }
                
                // Type-specific Section
                if let assetType = viewModel.selectedAssetType {
                    typeSpecificSection(assetType)
                }
                
                // Disclaimer
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 16))
                    
                    Text("İlanınız yayınlanmadan önce ekibimiz tarafından incelenecektir. İnceleme süreci 1-3 iş günü sürebilir.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    // MARK: - Type Specific Sections
    
    @ViewBuilder
    private func typeSpecificSection(_ type: AssetTypeOption) -> some View {
        switch type {
        case .property:
            previewSection("Gayrimenkul Detayları", icon: "building.2.fill") {
                previewRow("Kategori", viewModel.propertyCategory.title)
                previewRow("Şehir", viewModel.city)
                previewRow("Adres", viewModel.address)
                
                if !viewModel.latitude.isEmpty && !viewModel.longitude.isEmpty {
                    previewRow("Konum", "\(viewModel.latitude), \(viewModel.longitude)")
                }
                
                if !viewModel.spvName.isEmpty {
                    previewRow("SPV Şirket", viewModel.spvName)
                }
                
                if !viewModel.spvTaxNumber.isEmpty {
                    previewRow("SPV Vergi No", viewModel.spvTaxNumber)
                }
            }
            
        case .art:
            previewSection("Sanat Eseri Detayları", icon: "paintpalette.fill") {
                previewRow("Sanatçı", viewModel.artistName)
                previewRow("Teknik", viewModel.artTechnique.title)
                previewRow("Boyutlar", viewModel.artDimensions)
                
                if !viewModel.artYear.isEmpty {
                    previewRow("Yapım Yılı", viewModel.artYear)
                }
            }
            
        case .nft:
            previewSection("NFT Detayları", icon: "cube.transparent.fill") {
                previewRow("Koleksiyon", viewModel.collectionName)
                previewRow("Blockchain", viewModel.nftBlockchain.title)
                
                if !viewModel.contractAddress.isEmpty {
                    previewRow("Kontrat Adresi", viewModel.contractAddress)
                }
            }
        }
    }
    
    // MARK: - Preview Components
    
    private func previewSection(_ title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.accentColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                // Edit button
                Button {
                    navigateToRelevantStep(title)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                        Text("Düzenle")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            Divider()
            
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func previewRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 200)
            
            VStack(spacing: 8) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 32))
                    .foregroundStyle(.tertiary)
                Text("Görsel yüklenmedi")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private func navigateToRelevantStep(_ sectionTitle: String) {
        switch sectionTitle {
        case "Genel Bilgiler", "Finansal Bilgiler":
            viewModel.goToStep(.generalInfo)
        case let title where title.contains("Detay"):
            viewModel.goToStep(.typeDetails)
        default:
            break
        }
    }
}

#Preview {
    let vm = AddAssetViewModel()
    vm.title = "Kadıköy Sahil Residence"
    vm.description = "Moda sahil şeridinde deniz manzaralı, 120m² 3+1 daire."
    vm.totalValue = "2500000"
    vm.tokenPrice = "2500"
    vm.totalTokens = "1000"
    vm.annualYield = "8.5"
    vm.monthlyRent = "12500"
    vm.imageUrl = "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800"
    vm.badge = "Popüler"
    vm.selectedAssetType = .property
    vm.city = "İstanbul"
    vm.address = "Moda Caddesi No:42"
    vm.propertyCategory = .konut
    vm.currentStep = .preview
    return AddAssetStep4View(viewModel: vm)
}

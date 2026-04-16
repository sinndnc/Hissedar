//
//  AddAssetStep3View.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct AddAssetStep3View: View {
    
    @Bindable var viewModel: AddAssetViewModel
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case city, address, spvName, spvTaxNumber, latitude, longitude
        case artistName, artDimensions, artYear
        case collectionName, contractAddress
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.selectedAssetType {
                case .property:
                    propertyDetailsForm
                case .art:
                    artDetailsForm
                case .nft:
                    nftDetailsForm
                case .none:
                    emptyState
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Property Form
    
    private var propertyDetailsForm: some View {
        VStack(spacing: 24) {
            sectionHeader(
                icon: "building.2.fill",
                title: "Gayrimenkul Detayları",
                subtitle: "Mülkün konum ve hukuki bilgilerini girin",
                color: .blue
            )
            
            // Kategori Seçimi
            VStack(spacing: 16) {
                sectionLabel("Kategori")
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(PropertyCategory.allCases) { category in
                        categoryCard(category)
                    }
                }
            }
            .formSection()
            
            // Konum Bilgileri
            VStack(spacing: 16) {
                sectionLabel("Konum Bilgileri")
                
                // Şehir Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Şehir")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        ForEach(TurkishCities.all, id: \.self) { city in
                            Button(city) {
                                viewModel.city = city
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.tertiary)
                            
                            Text(viewModel.city.isEmpty ? "Şehir seçin..." : viewModel.city)
                                .font(.system(size: 16))
                                .foregroundStyle(viewModel.city.isEmpty ? .tertiary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                FormTextField(
                    label: "Adres",
                    placeholder: "Tam adres girin...",
                    text: $viewModel.address,
                    icon: "location.fill"
                )
                .focused($focusedField, equals: .address)
                
                HStack(spacing: 12) {
                    FormTextField(
                        label: "Enlem",
                        placeholder: "40.9827",
                        text: $viewModel.latitude,
                        icon: "globe",
                        keyboardType: .decimalPad
                    )
                    .focused($focusedField, equals: .latitude)
                    
                    FormTextField(
                        label: "Boylam",
                        placeholder: "29.0277",
                        text: $viewModel.longitude,
                        icon: "globe",
                        keyboardType: .decimalPad
                    )
                    .focused($focusedField, equals: .longitude)
                }
            }
            .formSection()
            
            // SPV Bilgileri
            VStack(spacing: 16) {
                sectionLabel("SPV Bilgileri (Opsiyonel)")
                
                FormTextField(
                    label: "SPV Şirket Adı",
                    placeholder: "örn: Kadıköy Sahil SPV A.Ş.",
                    text: $viewModel.spvName,
                    icon: "building.columns.fill"
                )
                .focused($focusedField, equals: .spvName)
                
                FormTextField(
                    label: "SPV Vergi Numarası",
                    placeholder: "1234567890",
                    text: $viewModel.spvTaxNumber,
                    icon: "number.circle.fill",
                    keyboardType: .numberPad
                )
                .focused($focusedField, equals: .spvTaxNumber)
            }
            .formSection()
        }
    }
    
    // MARK: - Art Form
    
    private var artDetailsForm: some View {
        VStack(spacing: 24) {
            sectionHeader(
                icon: "paintpalette.fill",
                title: "Sanat Eseri Detayları",
                subtitle: "Eserin sanatçı ve teknik bilgilerini girin",
                color: .purple
            )
            
            VStack(spacing: 16) {
                FormTextField(
                    label: "Sanatçı Adı",
                    placeholder: "örn: Devrim Erbil",
                    text: $viewModel.artistName,
                    icon: "person.fill"
                )
                .focused($focusedField, equals: .artistName)
                
                // Teknik Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Teknik")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        ForEach(ArtTechnique.allCases) { technique in
                            Button(technique.title) {
                                viewModel.artTechnique = technique
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.tertiary)
                            
                            Text(viewModel.artTechnique.title)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                HStack(spacing: 12) {
                    FormTextField(
                        label: "Boyutlar",
                        placeholder: "120x80 cm",
                        text: $viewModel.artDimensions,
                        icon: "ruler.fill"
                    )
                    .focused($focusedField, equals: .artDimensions)
                    
                    FormTextField(
                        label: "Yapım Yılı",
                        placeholder: "2023",
                        text: $viewModel.artYear,
                        icon: "calendar",
                        keyboardType: .numberPad
                    )
                    .focused($focusedField, equals: .artYear)
                }
            }
            .formSection()
        }
    }
    
    // MARK: - NFT Form
    
    private var nftDetailsForm: some View {
        VStack(spacing: 24) {
            sectionHeader(
                icon: "cube.transparent.fill",
                title: "NFT Detayları",
                subtitle: "Dijital varlığın blockchain bilgilerini girin",
                color: .orange
            )
            
            VStack(spacing: 16) {
                FormTextField(
                    label: "Koleksiyon Adı",
                    placeholder: "örn: Hissedar Genesis",
                    text: $viewModel.collectionName,
                    icon: "square.stack.3d.up.fill"
                )
                .focused($focusedField, equals: .collectionName)
                
                // Blockchain Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Blockchain")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(NFTBlockchain.allCases) { chain in
                            blockchainChip(chain)
                        }
                    }
                }
                
                FormTextField(
                    label: "Kontrat Adresi (Opsiyonel)",
                    placeholder: "0x...",
                    text: $viewModel.contractAddress,
                    icon: "link"
                )
                .focused($focusedField, equals: .contractAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .formSection()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Lütfen önce varlık türü seçin")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
            
            Button("Geri Dön") {
                viewModel.goBack()
            }
            .font(.system(size: 15, weight: .medium))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
    
    // MARK: - Components
    
    private func categoryCard(_ category: PropertyCategory) -> some View {
        let isSelected = viewModel.propertyCategory == category
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.propertyCategory = category
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : .blue)
                
                Text(category.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func blockchainChip(_ chain: NFTBlockchain) -> some View {
        let isSelected = viewModel.nftBlockchain == chain
        
        return Button {
            viewModel.nftBlockchain = chain
        } label: {
            Text(chain.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func sectionHeader(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(color)
            
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

#Preview {
    let vm = AddAssetViewModel()
    vm.selectedAssetType = .property
    return AddAssetStep3View(viewModel: vm)
}

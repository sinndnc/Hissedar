//
//  AddAssetStep3View.swift
//  Hissedar
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
                title: String.localized("wizard.step.2.property_title"),
                subtitle: String.localized("wizard.step.2.property_subtitle"),
                color: .blue
            )
            
            VStack(spacing: 16) {
                sectionLabel(String.localized("wizard.field.category.label"))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(PropertyCategory.allCases) { category in
                        categoryCard(category)
                    }
                }
            }
            .formSection()
            
            VStack(spacing: 16) {
                sectionLabel(String.localized("wizard.section.location"))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String.localized("wizard.field.city.label"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        ForEach(TurkishCities.all, id: \.self) { city in
                            Button(city) { viewModel.city = city }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "mappin.circle.fill").foregroundStyle(.tertiary)
                            Text(viewModel.city.isEmpty ? String.localized("wizard.field.city.placeholder") : viewModel.city)
                                .foregroundStyle(viewModel.city.isEmpty ? .tertiary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down").font(.system(size: 12)).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                FormTextField(label: String.localized("wizard.field.address.label"), placeholder: String.localized("wizard.field.address.placeholder"), text: $viewModel.address, icon: "location.fill")
                    .focused($focusedField, equals: .address)
                
                HStack(spacing: 12) {
                    FormTextField(label: String.localized("wizard.field.lat.label"), placeholder: "40.9827", text: $viewModel.latitude, icon: "globe", keyboardType: .decimalPad)
                        .focused($focusedField, equals: .latitude)
                    FormTextField(label: String.localized("wizard.field.lng.label"), placeholder: "29.0277", text: $viewModel.longitude, icon: "globe", keyboardType: .decimalPad)
                        .focused($focusedField, equals: .longitude)
                }
            }
            .formSection()
        }
    }
    
    // MARK: - Art Form
    private var artDetailsForm: some View {
        VStack(spacing: 24) {
            sectionHeader(icon: "paintpalette.fill", title: String.localized("wizard.step.2.art_title"), subtitle: String.localized("wizard.step.2.art_subtitle"), color: .purple)
            VStack(spacing: 16) {
                FormTextField(label: String.localized("wizard.field.artist.label"), placeholder: "örn: Devrim Erbil", text: $viewModel.artistName, icon: "person.fill")
                    .focused($focusedField, equals: .artistName)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String.localized("wizard.field.technique.label")).font(.system(size: 13, weight: .medium)).foregroundStyle(.secondary)
                    Menu {
                        ForEach(ArtTechnique.allCases) { tech in
                            Button(tech.title) { viewModel.artTechnique = tech }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill").foregroundStyle(.tertiary)
                            Text(viewModel.artTechnique.title).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.down").font(.system(size: 12)).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 12).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                HStack(spacing: 12) {
                    FormTextField(label: String.localized("wizard.field.dimensions.label"), placeholder: "120x80 cm", text: $viewModel.artDimensions, icon: "ruler.fill")
                    FormTextField(label: String.localized("wizard.field.year.label"), placeholder: "2023", text: $viewModel.artYear, icon: "calendar", keyboardType: .numberPad)
                }
            }
            .formSection()
        }
    }
    
    // MARK: - NFT Form
    private var nftDetailsForm: some View {
        VStack(spacing: 24) {
            sectionHeader(icon: "cube.transparent.fill", title: String.localized("wizard.step.2.nft_title"), subtitle: String.localized("wizard.step.2.nft_subtitle"), color: .orange)
            VStack(spacing: 16) {
                FormTextField(label: String.localized("wizard.field.collection.label"), placeholder: "örn: Hissedar Genesis", text: $viewModel.collectionName, icon: "square.stack.3d.up.fill")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Blockchain").font(.system(size: 13, weight: .medium)).foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(NFTBlockchain.allCases) { chain in
                            blockchainChip(chain)
                        }
                    }
                }
                FormTextField(label: String.localized("wizard.field.contract.label"), placeholder: "0x...", text: $viewModel.contractAddress, icon: "link")
                    .textInputAutocapitalization(.never)
            }
            .formSection()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 40)).foregroundStyle(.orange)
            Text(String.localized("wizard.error.select_type")).font(.system(size: 17, weight: .medium)).foregroundStyle(.secondary)
            Button(String.localized("common.back")) { viewModel.goBack() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(.top, 80)
    }
    
    // MARK: - Components (categoryCard, blockchainChip, etc. are kept internal)
    
    private func categoryCard(_ category: PropertyCategory) -> some View {
        let isSelected = viewModel.propertyCategory == category
        return Button { withAnimation { viewModel.propertyCategory = category } } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon).font(.system(size: 22)).foregroundStyle(isSelected ? .white : .blue)
                Text(category.title).font(.system(size: 13, weight: .medium)).foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func blockchainChip(_ chain: NFTBlockchain) -> some View {
        let isSelected = viewModel.nftBlockchain == chain
        return Button { viewModel.nftBlockchain = chain } label: {
            Text(chain.title).font(.system(size: 13, weight: .medium)).foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6)).clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func sectionHeader(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 36)).foregroundStyle(color)
            Text(title).font(.system(size: 22, weight: .bold))
            Text(subtitle).font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        HStack { Text(text).font(.system(size: 15, weight: .semibold)); Spacer() }
    }
}


// MARK: - Form TextField
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

// MARK: - Form TextEditor
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

// MARK: - View Extension for formSection
extension View {
    func formSection() -> some View {
        self.padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Turkish Cities Model
struct TurkishCities {
    static let all: [String] = [
        "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya",
        "Adana", "Konya", "Gaziantep", "Mersin", "Kayseri"
        // ... diğerlerini ekleyebilirsin
    ]
}

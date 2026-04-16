//
//  AddAssetViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI
import Foundation

@MainActor
@Observable
final class AddAssetViewModel {
    
    // MARK: - Wizard Navigation
    
    var currentStep: AddAssetStep = .generalInfo
    var isLoading = false
    var errorMessage: String?
    var submitSuccess = false
    
    // MARK: - Step 1: Genel Bilgiler
    
    var title: String = ""
    var description: String = ""
    var totalValue: String = ""
    var tokenPrice: String = ""
    var totalTokens: String = ""
    var annualYield: String = ""
    var monthlyRent: String = ""
    var imageUrl: String = ""
    var badge: String = ""
    
    // MARK: - Step 2: Asset Type
    
    var selectedAssetType: AssetTypeOption? = nil
    
    // MARK: - Step 3a: Property Details
    
    var city: String = ""
    var address: String = ""
    var propertyCategory: PropertyCategory = .konut
    var spvName: String = ""
    var spvTaxNumber: String = ""
    var latitude: String = ""
    var longitude: String = ""
    
    // MARK: - Step 3b: Art Details
    
    var artistName: String = ""
    var artTechnique: ArtTechnique = .yagliBoya
    var artDimensions: String = ""
    var artYear: String = ""
    
    // MARK: - Step 3c: NFT Details
    
    var collectionName: String = ""
    var nftBlockchain: NFTBlockchain = .polygon
    var contractAddress: String = ""
    
    // MARK: - Computed Properties
    
    var stepProgress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(AddAssetStep.totalSteps)
    }
    
    var canGoNext: Bool {
        switch currentStep {
        case .generalInfo:
            return !title.isEmpty && !totalValue.isEmpty && !tokenPrice.isEmpty && !totalTokens.isEmpty
        case .assetType:
            return selectedAssetType != nil
        case .typeDetails:
            return validateTypeDetails()
        case .preview:
            return true
        }
    }
    
    var isFirstStep: Bool { currentStep == .generalInfo }
    var isLastStep: Bool { currentStep == .preview }
    
    var calculatedTokenPrice: String {
        guard let total = Decimal(string: totalValue),
              let tokens = Int(totalTokens),
              tokens > 0 else { return "—" }
        let price = total / Decimal(tokens)
        return formatCurrency(price)
    }
    
    var calculatedMonthlyYield: String {
        guard let total = Decimal(string: totalValue),
              let yield_ = Double(annualYield),
              yield_ > 0 else { return "—" }
        let monthly = total * Decimal(yield_ / 100.0 / 12.0)
        return formatCurrency(monthly)
    }
    
    // MARK: - Navigation
    
    func goNext() {
        guard canGoNext else { return }
        if let nextStep = AddAssetStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = nextStep
            }
        }
    }
    
    func goBack() {
        if let prevStep = AddAssetStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = prevStep
            }
        }
    }
    
    func goToStep(_ step: AddAssetStep) {
        // Sadece önceki adımlara gidebilir
        guard step.rawValue <= currentStep.rawValue else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }
    
    // MARK: - Validation
    
    private func validateTypeDetails() -> Bool {
        guard let type = selectedAssetType else { return false }
        switch type {
        case .property:
            return !city.isEmpty && !address.isEmpty
        case .art:
            return !artistName.isEmpty && !artDimensions.isEmpty
        case .nft:
            return !collectionName.isEmpty
        }
    }
    
    // MARK: - Submit
    
    func submit() async {
        guard let assetType = selectedAssetType else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            switch assetType {
            case .property:
                try await submitProperty()
            case .art:
                try await submitArt()
            case .nft:
                try await submitNFT()
            }
            submitSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func submitProperty() async throws {
        // TODO: Supabase'e insert — MarketRepository üzerinden
        // let request = AddPropertyRequest(...)
        // try await repository.addProperty(request)
    }
    
    private func submitArt() async throws {
        // TODO: Supabase'e insert
    }
    
    private func submitNFT() async throws {
        // TODO: Supabase'e insert
    }
    
    // MARK: - Helpers
    
    func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₺"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "₺0"
    }
    
    func resetForm() {
        currentStep = .generalInfo
        title = ""
        description = ""
        totalValue = ""
        tokenPrice = ""
        totalTokens = ""
        annualYield = ""
        monthlyRent = ""
        imageUrl = ""
        badge = ""
        selectedAssetType = nil
        city = ""
        address = ""
        propertyCategory = .konut
        spvName = ""
        spvTaxNumber = ""
        latitude = ""
        longitude = ""
        artistName = ""
        artTechnique = .yagliBoya
        artDimensions = ""
        artYear = ""
        collectionName = ""
        nftBlockchain = .polygon
        contractAddress = ""
        errorMessage = nil
        submitSuccess = false
    }
}

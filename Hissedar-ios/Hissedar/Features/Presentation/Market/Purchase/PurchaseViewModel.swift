//
//  PurchaseViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation
import Factory

@MainActor
@Observable
final class PurchaseViewModel: BaseViewModel {
    
    private let repository = Container.shared.marketRepository()
    private let authService = Container.shared.authService()
    
    var error: String?
    var purchaseAmount: Int = 1
    var purchaseSuccess = false
    var blockchainStatus: String = ""
    var walletAddress: String = ""
    var asset: AssetItem
    
    init(asset: AssetItem) {
        self.asset = asset
    }
    
    var purchaseTotal: Decimal {
        return asset.currentValue * Decimal(purchaseAmount)
    }
    
    var formattedPurchaseTotal: String {
        "₺\(NSDecimalNumber(decimal: purchaseTotal).intValue.formatted())"
    }
    
    var isBlockchainPending: Bool {
        blockchainStatus == "pending"
    }
    
    func purchase() async {
        guard let userId = await authService.currentUserId?.lowercased() else { return }
        isLoading = true
        self.error = nil
        defer { isLoading = false }
        
        do {
            let result = try await repository.purchase(
                buyerId: userId,
                asset: asset,
                amount: purchaseAmount
            )
            
            blockchainStatus = result.blockchainStatus ?? "pending"
            walletAddress = result.walletAddress ?? ""
            
            purchaseSuccess = true
        } catch let catchError {
            Logger.log("ERROR: \(catchError)")
            self.error = catchError.localizedDescription
        }
    }
}

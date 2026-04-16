//
//  RentIncomeViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Realtime
import Combine
import Foundation

@MainActor
final class RentIncomeViewModel: ObservableObject {
    @Published var claimable: [String] = []
    @Published var isLoading  = false
    @Published var isClaiming = false
    @Published var successMessage: String?
    @Published var errorMessage: String?
    
    private var rentChannel: RealtimeChannelV2?
    
//    var totalClaimable: Decimal { claimable.reduce(0) { $0 + $1.amount } }
    
    func load(userId: String) async {
        isLoading = true; defer { isLoading = false }
//        do { claimable = try await supabase.fetchClaimableRent(userId: userId) }
//        catch { errorMessage = "Kira bilgisi yüklenemedi" }
//        
//        rentChannel = supabase.subscribeRentClaimable(userId: userId) { [weak self] item in
//            Task { @MainActor in
//                self?.claimable.append(item)
//                self?.successMessage = "Yeni kira geliriniz: \(item.amount.tlFormatted)"
//            }
//        }
    }
    
    func claimAll(userId: String) async {
        isClaiming = true; defer { isClaiming = false }
        try? await Task.sleep(nanoseconds: 1_500_000_000)
//        successMessage = "\(totalClaimable.tlFormatted) kira geliriniz işleme alındı"
    }
    
//    deinit { Task { [rentChannel] in await rentChannel?.unsubscribe() } }
}

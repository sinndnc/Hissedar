//
//  Container.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/26/26.
//

import Factory
import Supabase
import Foundation

extension Container {
    
    // MARK: - Core
    var supabaseClient: Factory<SupabaseClient> {
        self { @MainActor in
            SupabaseClient(
                supabaseURL: URL(string: Bundle.main.supabaseURL)!,
                supabaseKey: Bundle.main.supabaseAnonKey, options: .init(
                    auth: .init(
                        emitLocalSessionAsInitialSession: true
                    )
                )
            )
        }
        .singleton
    }
    var appState: Factory<AppState> {
        self { @MainActor in AppState() }.singleton
    }
    
    // MARK: - User
    var userRepository: Factory<UserRepositoryProtocol> {
        self { @MainActor in UserRepository() }.singleton
    }
    
    // MARK: - Auth
    var authRepository: Factory<AuthRepositoryProtocol> {
        self { @MainActor in AuthRepository() }.singleton
    }
    var authService: Factory<AuthServiceProtocol> {
        self { @MainActor in AuthService() }.singleton
    }
    var authViewModel: Factory<AuthViewModel> {
        self { @MainActor in AuthViewModel() }.singleton
    }
    
    // MARK: - Watchlist
    var watchlistRepository: Factory<WatchlistRepositoryProtocol> {
        self { @MainActor in WatchlistRepository() }.singleton
    }
    var watchlistService: Factory<WatchlistServiceProtocol> {
        self { @MainActor in WatchlistService() }.singleton
    }
    var watchlistViewModel: Factory<WatchlistViewModel> {
        self { @MainActor in WatchlistViewModel() }.singleton
    }
    
    // MARK: - Portfolio
    var portfolioRepository: Factory<PortfolioRepositoryProtocol> {
        self { @MainActor in PortfolioRepository() }.singleton
    }
    var portfolioService: Factory<PortfolioServiceProtocol> {
        self { @MainActor in PortfolioService() }.singleton
    }
    var portfolioViewModel: Factory<PortfolioViewModel> {
        self { @MainActor in PortfolioViewModel() }.singleton
    }
    
    // MARK: - Market
    var marketService: Factory<MarketServiceProtocol> {
        self { @MainActor in MarketService() }.singleton
    }
    var marketRepository: Factory<MarketRepositoryProtocol> {
        self { @MainActor in MarketRepository() }.singleton
    }
    var marketViewModel: Factory<MarketViewModel> {
        self { @MainActor in MarketViewModel() }.singleton
    }
    
    // MARK: - Blockchain
    var blockchainRepository: Factory<BlockchainRepositoryProtocol> {
        self { @MainActor in BlockchainRepository(client: self.supabaseClient()) }
            .singleton
    }
    var blockchainService: Factory<BlockchainServiceProtocol> {
        self { @MainActor in BlockchainService(repository: self.blockchainRepository()) }
            .singleton
    }
    var walletViewModel: Factory<WalletViewModel> {
        self { @MainActor in WalletViewModel() }.singleton
    }
    
    // MARK: - Profile
    var profileViewModel: Factory<ProfileViewModel> {
        self { @MainActor in ProfileViewModel() }.singleton
    }
    
    var notificationViewModel: Factory<NotificationsViewModel> {
        self { @MainActor in NotificationsViewModel() }.singleton
    }
    
    var notificationSettingsViewModel: Factory<NotificationSettingsViewModel> {
        self { @MainActor in NotificationSettingsViewModel() }.singleton
    }
    
    // MARK: - Exchange
    var exchangeRepository: Factory<ExchangeRepositoryProtocol> {
        self { @MainActor in ExchangeRepository() }.singleton
    }
    
    // MARK: - Rent
    var rentService: Factory<RentServiceProtocol> {
        self { @MainActor in RentService() }.singleton
    }
    
    var rentViewModel: Factory<RentHistoryViewModel> {
        self { @MainActor in RentHistoryViewModel() }.singleton
    }
    
    // MARK: Price Alert
    var priceAlertsService: Factory<PriceAlertsService> {
        Factory(self) { @MainActor in SupabasePriceAlertsService() }
            .singleton
    }
}

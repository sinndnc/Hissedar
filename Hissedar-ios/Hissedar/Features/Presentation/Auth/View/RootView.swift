//
//  RootView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct RootView: View {
    @Binding public var selectedTab: AppTab
    @State private var showPostRegister = false
    
    @Environment(AppState.self) var appState: AppState
    
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var body: some View {
        Group {
            if !onboardingCompleted {
                OnboardingFlowView(isCompleted: $onboardingCompleted)
                    .transition(.opacity)
            } else {
                switch appState.authState {
                case .loading:
                    SplashView()
                case .unauthenticated:
                    AuthFlowView(onRegistered: { showPostRegister = true })
                case .authenticated:
                    if showPostRegister {
                        PostRegisterView(
                            onKYC:    { showPostRegister = false },
                            onBrowse: { showPostRegister = false }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        MainTabView(selectedTab: $selectedTab)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: onboardingCompleted)
        .animation(.easeInOut(duration: 0.35), value: showPostRegister)
    }
}

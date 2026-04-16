import SwiftUI
import Combine

struct AuthFlowView: View {
    var onRegistered: (() -> Void)? = nil
    @StateObject private var authVm = AuthViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if authVm.isRegistering {
                    RegisterView(onRegistered: onRegistered)
                }
                else {
                    LoginView()
                }
            }
            .environmentObject(authVm)
            .animation(.easeInOut(duration: 0.22), value: authVm.isRegistering)
        }
    }
}

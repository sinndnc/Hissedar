import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let id: Int
    let style: PageStyle
    let step: String?
    let title: String
    let subtitle: String

    enum PageStyle { case welcome, feature, dark, trust }
}

// MARK: - Onboarding Flow
struct OnboardingFlowView: View {
    @Binding var isCompleted: Bool
    @State private var currentPage = 0

    private var pages: [OnboardingPage] {
        [
            .init(id: 0, style: .welcome,
                  step: nil,
                  title: String.localized("onboarding.page0.title"),
                  subtitle: String.localized("onboarding.page0.subtitle")),
            .init(id: 1, style: .feature,
                  step: String.localized("onboarding.page1.step"),
                  title: String.localized("onboarding.page1.title"),
                  subtitle: String.localized("onboarding.page1.subtitle")),
            .init(id: 2, style: .dark,
                  step: String.localized("onboarding.page2.step"),
                  title: String.localized("onboarding.page2.title"),
                  subtitle: String.localized("onboarding.page2.subtitle")),
            .init(id: 3, style: .trust,
                  step: String.localized("onboarding.page3.step"),
                  title: String.localized("onboarding.page3.title"),
                  subtitle: String.localized("onboarding.page3.subtitle")),
        ]
    }

    var body: some View {
        ZStack {
            // Arka plan
            switch pages[currentPage].style {
            case .dark: Color.hsBackground.ignoresSafeArea()
            default:    Color.hsBackground.ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Atla butonu
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(String.localized("common.skip")) { complete() }
                            .font(.hCaption)
                            .foregroundStyle(Color.hsPurple600.opacity(0.7))
                            .padding(.trailing, 24)
                    }
                }
                .frame(height: 56 + 20)
                .padding(.top, 0)

                // Sayfa içeriği
                switch pages[currentPage].style {
                case .welcome: WelcomePage()
                case .feature: TokenizationPage()
                case .dark:    RentPage()
                case .trust:   TrustPage()
                }

                // Alt kontroller
                VStack(spacing: 16) {
                    HStack(spacing: 6) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(
                                    i == currentPage ? Color.hsPurple600 : Color.hsTextSecondary
                                )
                                .frame(width: i == currentPage ? 20 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.25), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.35)) { currentPage += 1 }
                        } else {
                            complete()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? String.localized("common.continue") : String.localized("onboarding.action.create_account"))
                            .font(.hHeadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.hsPurple600)
                            .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                    }

                    if currentPage == 0 {
                        Button(String.localized("onboarding.action.login")) { complete() }
                            .font(.hCaption)
                            .foregroundStyle(Color.hsTextPrimary.opacity(0.8))
                    } else {
                        Color.clear.frame(height: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
                .padding(.top, 12)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.35), value: currentPage)
        .gesture(
            DragGesture().onEnded { val in
                if val.translation.width < -60, currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.35)) { currentPage += 1 }
                } else if val.translation.width > 60, currentPage > 0 {
                    withAnimation(.easeInOut(duration: 0.35)) { currentPage -= 1 }
                }
            }
        )
    }

    private func complete() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        withAnimation(.easeInOut(duration: 0.4)) { isCompleted = true }
    }
}

// MARK: - Sayfa 1: Karşılama
struct WelcomePage: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.hsPurple600.opacity(0.15))
                    .frame(width: 180, height: 180)
                HStack(alignment: .bottom, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple600.opacity(0.6)).frame(width: 34, height: 64)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple200).frame(width: 42, height: 90)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple600.opacity(0.8)).frame(width: 34, height: 72)
                }
                .offset(y: 10)
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 36)

            VStack(spacing: 10) {
                Text(String.localized("onboarding.page0.title"))
                    .font(.hDisplay).foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                Text(String.localized("onboarding.page0.subtitle"))
                    .font(.hBody).foregroundStyle(Color.hsTextSecondary)
                    .multilineTextAlignment(.center).lineSpacing(4)
            }
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appeared = true }
        }
    }
}

// MARK: - Sayfa 2: Tokenizasyon
struct TokenizationPage: View {
    @State private var appeared   = false
    @State private var tokenPulse = false

    var body: some View {
        VStack(spacing: 0) {
            stepLabel(String.localized("onboarding.page1.step"))
            Text(String.localized("onboarding.page1.title"))
                .font(.hTitle).foregroundStyle(Color.hsTextPrimary)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple600.opacity(0.5)).frame(width: 36, height: 56)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple600).frame(width: 44, height: 80)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hsPurple600.opacity(0.7)).frame(width: 36, height: 64)
                }
                Text(String.localized("onboarding.token.property_value")).font(.hCaption).foregroundStyle(Color.hsTextPrimary).padding(.top, 8)
                Image(systemName: "arrow.down").font(.system(size: 16)).foregroundStyle(Color.hsTextPrimary.opacity(0.6)).padding(.vertical, 8)
                Text(String.localized("onboarding.token.count")).font(.hCaptionMed).foregroundStyle(Color.hsTextPrimary).padding(.bottom, 10)

                LazyVGrid(columns: Array(repeating: .init(.fixed(36)), count: 9), spacing: 6) {
                    ForEach(0..<9, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(i == 3 ? Color.hsTextPrimary : Color.hsPurple600.opacity(0.7))
                            .frame(width: 36, height: 28)
                            .overlay(Text(i == 3 ? String.localized("common.you") : "₺").font(.system(size: 9, weight: .bold)).foregroundStyle(.white))
                            .scaleEffect(i == 3 && tokenPulse ? 1.12 : 1)
                            .animation(i == 3 ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: tokenPulse)
                    }
                }
            }
            .padding(20)
            .background(Color.hsBackground)
            .clipShape(RoundedRectangle(cornerRadius: .hRadiusLg))
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)

            Spacer().frame(height: 20)

            VStack(spacing: 12) {
                FeatureRow(icon: "checkmark.circle.fill", title: String.localized("onboarding.token.feat1_title"), desc: String.localized("onboarding.token.feat1_desc"))
                FeatureRow(icon: "plus.circle.fill",      title: String.localized("onboarding.token.feat2_title"), desc: String.localized("onboarding.token.feat2_desc"))
            }
            .padding(.horizontal, 24).opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { tokenPulse = true }
        }
    }
}

// MARK: - Sayfa 3: Kira Geliri
struct RentPage: View {
    @State private var appeared = false
    private let bars: [CGFloat] = [0.4, 0.55, 0.45, 0.6, 0.5, 0.65, 0.55, 0.8, 0.85, 0.9, 0.95, 1.0]

    var body: some View {
        VStack(spacing: 0) {
            stepLabel(String.localized("onboarding.page2.step"))
            Text(String.localized("onboarding.page2.title"))
                .font(.hTitle).foregroundStyle(Color.hsTextPrimary)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(String.localized("onboarding.rent.sample_location")).font(.hCaptionMed).foregroundStyle(Color.hsTextPrimary)
                    Spacer()
                    Text(String.localized("onboarding.rent.sample_token_count")).font(.hCaption).foregroundStyle(Color.hsTextPrimary)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.hsTextPrimary.opacity(0.15)).clipShape(Capsule())
                }
                Text("₺3.200").font(.hDisplay).foregroundStyle(Color.hsTextPrimary)
                Text(String.localized("onboarding.rent.pay_period")).font(.hCaption).foregroundStyle(Color.hsTextPrimary)
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(bars.indices, id: \.self) { i in
                        Capsule()
                            .fill(i >= bars.count - 5 ? Color.hsTextPrimary : Color.hsTextSecondary)
                            .frame(height: 48 * bars[i]).frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 48).padding(.top, 4)
            }
            .padding(18)
            .background(Color.hsBackground)
            .clipShape(RoundedRectangle(cornerRadius: .hRadiusLg))
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 16)

            VStack(spacing: 8) {
                SimRow(label: String.localized("onboarding.rent.sim1_label"),    value: "₺50.000")
                SimRow(label: String.localized("onboarding.rent.sim2_label"), value: "₺4.200 / yıl")
                SimRow(label: String.localized("onboarding.rent.sim3_label"), value: "+%8.4")
            }
            .padding(.horizontal, 24).opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true } }
    }
}

// MARK: - Sayfa 4: Güven
struct TrustPage: View {
    @State private var appeared = false
    private let items: [(String, String, String)] = [
        ("building.columns.fill", String.localized("onboarding.trust.item1_title"), String.localized("onboarding.trust.item1_desc")),
        ("link",                  String.localized("onboarding.trust.item2_title"), String.localized("onboarding.trust.item2_desc")),
        ("person.badge.shield.checkmark.fill", String.localized("onboarding.trust.item3_title"), String.localized("onboarding.trust.item3_desc")),
    ]

    var body: some View {
        VStack(spacing: 0) {
            stepLabel(String.localized("onboarding.page3.step"))
            Text(String.localized("onboarding.page3.title"))
                .font(.hTitle).foregroundStyle(Color.hsTextPrimary)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(spacing: 10) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.hsPurple600)
                                .frame(width: 44, height: 44)
                            Image(systemName: items[i].0)
                                .font(.system(size: 18))
                                .foregroundStyle(Color.hsPurple300)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(items[i].1).font(.hBodyMedium).foregroundStyle(Color.hsTextPrimary)
                            Text(items[i].2).font(.hCaption).foregroundStyle(Color.hsTextPrimary).lineSpacing(2)
                        }
                    }
                    .padding(14).background(Color.hsBackgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                    .overlay(RoundedRectangle(cornerRadius: .hRadiusMd).strokeBorder(Color.hsBorder, lineWidth: 0.5))
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.4).delay(Double(i) * 0.1), value: appeared)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 14)

            HStack(spacing: 8) {
                ForEach([String.localized("onboarding.trust.tag1"), String.localized("onboarding.trust.tag2"), String.localized("onboarding.trust.tag3")], id: \.self) { label in
                    Text(label).font(.hLabel).foregroundStyle(Color.hsTextPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.hsPurple600)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.hsBackgroundSecondary,lineWidth: 1))
                }
            }
            .opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true } }
    }
}

// MARK: - Kayıt Sonrası Ekran
struct PostRegisterView: View {
    let onKYC:    () -> Void
    let onBrowse: () -> Void
    @State private var appeared = false

    private let steps = [
        (String.localized("post_register.step1"), true),
        (String.localized("post_register.step2"), false),
        (String.localized("post_register.step3"), false)
    ]

    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.hsPurple500.opacity(0.18))
                        .frame(width: 88, height: 88)
                    Circle().strokeBorder(Color.hsPurple500.opacity(0.4), lineWidth: 2).frame(width: 88, height: 88)
                    Image(systemName: "checkmark").font(.system(size: 32, weight: .semibold)).foregroundStyle(Color.hsPurple500)
                }
                .scaleEffect(appeared ? 1 : 0.5).opacity(appeared ? 1 : 0)

                Spacer().frame(height: 24)

                Text(String.localized("post_register.title"))
                    .font(.hTitle)
                    .foregroundStyle(Color.hsTextPrimary)
                Text(String.localized("post_register.subtitle"))
                    .font(.hBody)
                    .foregroundStyle(Color.hsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6).padding(.horizontal, 32)

                Spacer().frame(height: 32)

                VStack(spacing: 0) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 14) {
                            ZStack {
                                if steps[i].1 {
                                    Circle().fill(Color.hsPurple500).frame(width: 26, height: 26)
                                    Image(systemName: "checkmark").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                                } else {
                                    Circle()
                                        .strokeBorder(
                                            Color.hsTextSecondary.opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                        .frame(width: 26, height: 26)
                                }
                            }
                            Text(steps[i].0).font(.hBody)
                                .foregroundStyle(
                                    steps[i].1 ? Color.hsTextPrimary : Color.hsTextSecondary.opacity(0.6)
                                )
                            Spacer()
                        }
                        .padding(.vertical, 12).padding(.horizontal, 20)
                        if i < steps.count - 1 {
                            Divider()
                                .background(Color.hsTextSecondary.opacity(0.1))
                                .padding(.leading, 54)
                        }
                    }
                }
                .background(Color.hsBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                Spacer()

                VStack(spacing: 10) {
                    Button(action: onKYC) {
                        Text(String.localized("post_register.action.complete_kyc")).font(.hHeadline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.hsPurple500).clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                    }
                    Button(action: onBrowse) {
                        Text(String.localized("post_register.action.browse"))
                            .font(.hHeadline)
                            .foregroundStyle(Color.hsTextSecondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                            .overlay(RoundedRectangle(cornerRadius: .hRadiusMd).strokeBorder(Color.hsPurple500.opacity(0.3), lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 44)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.15)) { appeared = true }
        }
    }
}

// MARK: - Yardımcı görünümler
private func stepLabel(_ text: String) -> some View {
    Text(text).font(.hLabel).foregroundStyle(Color.hsPurple500).padding(.top, 56)
}

// MARK: - FeatureRow
struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(themeManager.theme.textPrimary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.hBodyMedium)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Text(desc)
                    .font(.hCaption)
                    .foregroundStyle(themeManager.theme.textSecondary.opacity(0.8))
            }
        }
    }
}

// MARK: - SimRow
struct SimRow: View {
    let label: String
    let value: String
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack {
            Text(label)
                .font(.hCaption)
                .foregroundStyle(themeManager.theme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.hBodyMedium)
                .foregroundStyle(themeManager.theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }
}

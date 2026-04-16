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

    private let pages: [OnboardingPage] = [
        .init(id: 0, style: .welcome,
              step: nil,
              title: "Gayrimenkule\nortak ol",
              subtitle: "₺100'den başlayan tokenlarla İstanbul'un en değerli mülklerine yatırım yap"),
        .init(id: 1, style: .feature,
              step: "Nasıl çalışır? · 1/3",
              title: "Büyük mülkler\nküçük parçalara bölünür",
              subtitle: "Her mülk binlerce token'a bölünür. Sen istediğin kadar alırsın — minimum ₺100."),
        .init(id: 2, style: .dark,
              step: "Nasıl çalışır? · 2/3",
              title: "Her ay kira geliri\notomatik yatırılır",
              subtitle: "Mülk kira geliri token oranında hesabına yansır. Dilediğinde çekebilirsin."),
        .init(id: 3, style: .trust,
              step: "Nasıl çalışır? · 3/3",
              title: "Güvenli, şeffaf\nve denetimli",
              subtitle: "Her mülk ayrı bir SPV şirketine bağlıdır. Tapu korumalı, blockchain şeffaf."),
    ]

    var body: some View {
        ZStack {
            // Arka plan
            switch pages[currentPage].style {
            case .dark: Color.hObsidian.ignoresSafeArea()
            default:    Color.hForest.ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Atla butonu
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Atla") { complete() }
                            .font(.hCaption)
                            .foregroundStyle(Color.hMint.opacity(0.7))
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
                                .fill(i == currentPage ? Color.hJade : Color.hMint.opacity(0.25))
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
                        Text(currentPage < pages.count - 1 ? "Devam" : "Hesap Oluştur")
                            .font(.hHeadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.hEmerald)
                            .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                    }

                    if currentPage == 0 {
                        Button("Hesabım var, giriş yap") { complete() }
                            .font(.hCaption)
                            .foregroundStyle(Color.hMint.opacity(0.8))
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
                Circle().fill(Color.hEmerald.opacity(0.15)).frame(width: 180, height: 180)
                HStack(alignment: .bottom, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.hEmerald.opacity(0.6)).frame(width: 34, height: 64)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hJade).frame(width: 42, height: 90)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hEmerald.opacity(0.8)).frame(width: 34, height: 72)
                }
                .offset(y: 10)
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 36)

            VStack(spacing: 10) {
                Text("Gayrimenkule\nortak ol")
                    .font(.hDisplay).foregroundStyle(Color.hWhite)
                    .multilineTextAlignment(.center)
                Text("₺100'den başlayan tokenlarla\nİstanbul'un en değerli mülklerine yatırım yap")
                    .font(.hBody).foregroundStyle(Color.hMint)
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
            stepLabel("Nasıl çalışır? · 1/3")
            Text("Büyük mülkler\nküçük parçalara bölünür")
                .font(.hTitle).foregroundStyle(Color.hWhite)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.hEmerald.opacity(0.5)).frame(width: 36, height: 56)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hEmerald).frame(width: 44, height: 80)
                    RoundedRectangle(cornerRadius: 4).fill(Color.hEmerald.opacity(0.7)).frame(width: 36, height: 64)
                }
                Text("₺5.000.000 değerinde mülk").font(.hCaption).foregroundStyle(Color.hSilver).padding(.top, 8)
                Image(systemName: "arrow.down").font(.system(size: 16)).foregroundStyle(Color.hMint.opacity(0.6)).padding(.vertical, 8)
                Text("50.000 token").font(.hCaptionMed).foregroundStyle(Color.hMint).padding(.bottom, 10)

                LazyVGrid(columns: Array(repeating: .init(.fixed(36)), count: 9), spacing: 6) {
                    ForEach(0..<9, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(i == 3 ? Color.hGold : Color.hEmerald.opacity(0.7))
                            .frame(width: 36, height: 28)
                            .overlay(Text(i == 3 ? "Sen" : "₺").font(.system(size: 9, weight: .bold)).foregroundStyle(.white))
                            .scaleEffect(i == 3 && tokenPulse ? 1.12 : 1)
                            .animation(i == 3 ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: tokenPulse)
                    }
                }
            }
            .padding(20)
            .background(Color.hForestMid)
            .clipShape(RoundedRectangle(cornerRadius: .hRadiusLg))
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)

            Spacer().frame(height: 20)

            VStack(spacing: 12) {
                FeatureRow(icon: "checkmark.circle.fill", title: "Minimum ₺100", desc: "Küçük yatırımla büyük mülke ortak ol")
                FeatureRow(icon: "plus.circle.fill",      title: "İstediğin kadar al", desc: "1 token'dan istediğin miktara kadar")
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
            stepLabel("Nasıl çalışır? · 2/3")
            Text("Her ay kira geliri\notomatik yatırılır")
                .font(.hTitle).foregroundStyle(Color.hWhite)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Kadıköy Moda 3+1").font(.hCaptionMed).foregroundStyle(Color.hWhite)
                    Spacer()
                    Text("500 token").font(.hCaption).foregroundStyle(Color.hJade)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.hJade.opacity(0.15)).clipShape(Capsule())
                }
                Text("₺3.200").font(.hDisplay).foregroundStyle(Color.hWhite)
                Text("Ocak 2025 kira payın").font(.hCaption).foregroundStyle(Color.hSilver)
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(bars.indices, id: \.self) { i in
                        Capsule()
                            .fill(i >= bars.count - 5 ? Color.hJade : Color.hSlate)
                            .frame(height: 48 * bars[i]).frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 48).padding(.top, 4)
            }
            .padding(18)
            .background(Color.hCharcoal)
            .clipShape(RoundedRectangle(cornerRadius: .hRadiusLg))
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 16)

            VStack(spacing: 8) {
                SimRow(label: "500 token yatırım",    value: "₺50.000")
                SimRow(label: "Yıllık kira getirisi", value: "₺4.200 / yıl")
                SimRow(label: "Tahmini değer artışı", value: "+%8.4")
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
        ("building.columns.fill", "SPV ile yasal sahiplik",      "Her mülk ayrı şirkete bağlı. Tapu kaydı korunur, senin adına tutulur."),
        ("link",                  "Blockchain şeffaflığı",        "Her işlem Polygon ağında kayıt altına alınır. İstediğin zaman doğrula."),
        ("person.badge.shield.checkmark.fill", "KYC zorunluluğu", "Yalnızca kimliği doğrulanmış kullanıcılar yatırım yapabilir."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            stepLabel("Nasıl çalışır? · 3/3")
            Text("Güvenli, şeffaf\nve denetimli")
                .font(.hTitle).foregroundStyle(Color.hWhite)
                .multilineTextAlignment(.center).padding(.horizontal, 24).padding(.top, 6)

            Spacer().frame(height: 24)

            VStack(spacing: 10) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.hMist).frame(width: 44, height: 44)
                            Image(systemName: items[i].0).font(.system(size: 18)).foregroundStyle(Color.hEmerald)
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
                ForEach(["SPK Denetimi", "SSL Şifreli", "2FA Koruma"], id: \.self) { label in
                    Text(label).font(.hLabel).foregroundStyle(Color.hEmerald)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.hMist)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.hFoam, lineWidth: 1))
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

    private let steps = [("Hesap oluşturuldu", true), ("Kimlik doğrulama (KYC)", false), ("İlk yatırımı yap", false)]

    var body: some View {
        ZStack {
            Color.hForest.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Circle().fill(Color.hJade.opacity(0.18)).frame(width: 88, height: 88)
                    Circle().strokeBorder(Color.hJade.opacity(0.4), lineWidth: 2).frame(width: 88, height: 88)
                    Image(systemName: "checkmark").font(.system(size: 32, weight: .semibold)).foregroundStyle(Color.hJade)
                }
                .scaleEffect(appeared ? 1 : 0.5).opacity(appeared ? 1 : 0)

                Spacer().frame(height: 24)

                Text("Hesabın oluşturuldu!").font(.hTitle).foregroundStyle(Color.hWhite)
                Text("Yatırıma başlamak için birkaç adım kaldı")
                    .font(.hBody).foregroundStyle(Color.hMint).multilineTextAlignment(.center)
                    .padding(.top, 6).padding(.horizontal, 32)

                Spacer().frame(height: 32)

                VStack(spacing: 0) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 14) {
                            ZStack {
                                if steps[i].1 {
                                    Circle().fill(Color.hJade).frame(width: 26, height: 26)
                                    Image(systemName: "checkmark").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                                } else {
                                    Circle().strokeBorder(Color.hMint.opacity(0.3), lineWidth: 1.5).frame(width: 26, height: 26)
                                }
                            }
                            Text(steps[i].0).font(.hBody)
                                .foregroundStyle(steps[i].1 ? Color.hWhite : Color.hFoam.opacity(0.6))
                            Spacer()
                        }
                        .padding(.vertical, 12).padding(.horizontal, 20)
                        if i < steps.count - 1 { Divider().background(Color.hMint.opacity(0.1)).padding(.leading, 54) }
                    }
                }
                .background(Color.hForestMid.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                Spacer()

                VStack(spacing: 10) {
                    Button(action: onKYC) {
                        Text("KYC'yi Tamamla").font(.hHeadline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.hEmerald).clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                    }
                    Button(action: onBrowse) {
                        Text("Mülklere Göz At").font(.hHeadline).foregroundStyle(Color.hMint)
                            .frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: .hRadiusMd))
                            .overlay(RoundedRectangle(cornerRadius: .hRadiusMd).strokeBorder(Color.hMint.opacity(0.3), lineWidth: 1.5))
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
    Text(text).font(.hLabel).foregroundStyle(Color.hMint).padding(.top, 56)
}

struct FeatureRow: View {
    let icon: String; let title: String; let desc: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(Color.hJade).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.hBodyMedium).foregroundStyle(Color.hWhite)
                Text(desc).font(.hCaption).foregroundStyle(Color.hMint.opacity(0.8))
            }
        }
    }
}

struct SimRow: View {
    let label: String; let value: String
    var body: some View {
        HStack {
            Text(label).font(.hCaption).foregroundStyle(Color.hSilver)
            Spacer()
            Text(value).font(.hBodyMedium).foregroundStyle(Color.hJade)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.hCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

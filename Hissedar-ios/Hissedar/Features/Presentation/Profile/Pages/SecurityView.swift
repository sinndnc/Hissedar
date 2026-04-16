import SwiftUI

// MARK: - Security View
struct SecurityView: View {
    
    @State private var biometricEnabled = true
    @State private var twoFactorEnabled = false
    @State private var loginAlerts = true
    @State private var showChangePassword = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                securityScore
                authSection
                passwordSection
                sessionsSection
                dangerZone
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Güvenlik")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Security Score
    private var securityScore: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.hWhite.opacity(0.06), lineWidth: 8)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(colors: [Color.hJade, Color.hEmerald], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("75")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.hWhite)
                    Text("/100")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.hsTextPrimary)
                }
            }
            
            VStack(spacing: 4) {
                Text("Güvenlik Puanı: İyi")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                
                Text("2FA'yı etkinleştirerek puanınızı artırın")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.hJade.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Auth Section
    private var authSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kimlik Doğrulama")
                .font(.hCaptionMed)
                .foregroundStyle(Color.hsTextPrimary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                SecurityToggleRow(
                    icon: "faceid",
                    title: "Biyometrik Giriş",
                    subtitle: "Face ID / Touch ID ile giriş",
                    isOn: $biometricEnabled,
                    accentColor: .hJade
                )
                
                Divider().background(Color.hWhite.opacity(0.06)).padding(.leading, 56)
                
                SecurityToggleRow(
                    icon: "lock.shield.fill",
                    title: "İki Faktörlü Doğrulama",
                    subtitle: "SMS veya Authenticator ile",
                    isOn: $twoFactorEnabled,
                    accentColor: .hGold
                )
                
                Divider().background(Color.hWhite.opacity(0.06)).padding(.leading, 56)
                
                SecurityToggleRow(
                    icon: "bell.badge.fill",
                    title: "Giriş Uyarıları",
                    subtitle: "Yeni cihaz girişlerinde bildir",
                    isOn: $loginAlerts,
                    accentColor: .hMint
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Password Section
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Şifre")
                .font(.hCaptionMed)
                .foregroundStyle(Color.hsTextPrimary)
                .padding(.leading, 4)
            
            Button {
                showChangePassword = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.hGold.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "key.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Şifre Değiştir")
                            .font(.hBody)
                            .foregroundStyle(Color.hWhite)
                        
                        Text("Son değişiklik: 45 gün önce")
                            .font(.hLabel)
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.hsBackgroundSecondary)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Sessions
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Aktif Oturumlar")
                    .font(.hCaptionMed)
                    .foregroundStyle(Color.hsTextPrimary)
                
                Spacer()
                
                Button {
                    // End all sessions
                } label: {
                    Text("Tümünü Kapat")
                        .font(.hLabel)
                        .foregroundStyle(Color.hRust)
                }
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(SessionItem.samples) { session in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.hWhite.opacity(0.05))
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: session.icon)
                                .font(.system(size: 15))
                                .foregroundStyle(session.isCurrent ? Color.hJade : Color.hsTextPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(session.device)
                                    .font(.hBody)
                                    .foregroundStyle(Color.hWhite)
                                
                                if session.isCurrent {
                                    Text("Bu cihaz")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(Color.hJade)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(Color.hJade.opacity(0.12)))
                                }
                            }
                            
                            Text("\(session.location) • \(session.lastActive)")
                                .font(.hLabel)
                                .foregroundStyle(Color.hsTextPrimary)
                        }
                        
                        Spacer()
                        
                        if !session.isCurrent {
                            Button {
                                // End session
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.hsTextPrimary.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    
                    if session.id != SessionItem.samples.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 56)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tehlikeli Bölge")
                .font(.hCaptionMed)
                .foregroundStyle(Color.hRust)
                .padding(.leading, 4)
            
            Button {
                // Delete account
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.hRust.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hRust)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hesabı Sil")
                            .font(.hBody)
                            .foregroundStyle(Color.hRust)
                        
                        Text("Bu işlem geri alınamaz")
                            .font(.hLabel)
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hRust.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.hsBackgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.hRust.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Security Toggle Row
struct SecurityToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(isOn ? 0.12 : 0.05))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isOn ? accentColor : Color.hsTextPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Text(subtitle)
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.hJade))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Session Model
struct SessionItem: Identifiable {
    let id = UUID()
    let device: String
    let icon: String
    let location: String
    let lastActive: String
    let isCurrent: Bool
    
    static let samples: [SessionItem] = [
        SessionItem(device: "iPhone 15 Pro", icon: "iphone", location: "İstanbul", lastActive: "Şu an aktif", isCurrent: true),
        SessionItem(device: "MacBook Pro", icon: "laptopcomputer", location: "İstanbul", lastActive: "2 saat önce", isCurrent: false),
        SessionItem(device: "iPad Air", icon: "ipad", location: "Ankara", lastActive: "3 gün önce", isCurrent: false),
    ]
}

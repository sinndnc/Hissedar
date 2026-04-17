import SwiftUI
//
//  SecurityView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import SwiftUI

// MARK: - Security View
struct SecurityView: View {
    
    @State private var biometricEnabled = true
    @State private var twoFactorEnabled = false
    @State private var loginAlerts = true
    @State private var showChangePassword = false
    @Environment(ThemeManager.self) private var themeManager
    
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
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("security.nav_title"))
                    .font(.hHeadline)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
    }
    
    // MARK: - Security Score
    private var securityScore: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(themeManager.theme.textPrimary.opacity(0.06), lineWidth: 8)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.theme.purple900,
                                themeManager.theme.purple400,
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("75")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(themeManager.theme.textPrimary)
                    Text("/100")
                        .font(.system(size: 11))
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
            }
            
            VStack(spacing: 4) {
                Text("\(String.localized("security.score.label")): \(String.localized("security.score.status_good"))")
                    .font(.hBodyMedium)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Text(String.localized("security.score.hint"))
                    .font(.hLabel)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.theme.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.theme.accent.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Auth Section
    private var authSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: String.localized("security.section.auth"))
            
            VStack(spacing: 0) {
                SecurityToggleRow(
                    icon: "faceid",
                    title: String.localized("security.auth.biometric.title"),
                    subtitle: String.localized("security.auth.biometric.desc"),
                    isOn: $biometricEnabled,
                    accentColor: themeManager.theme.accent
                )
                
                Divider().background(themeManager.theme.textPrimary.opacity(0.06)).padding(.leading, 56)
                
                SecurityToggleRow(
                    icon: "lock.shield.fill",
                    title: String.localized("security.auth.2fa.title"),
                    subtitle: String.localized("security.auth.2fa.desc"),
                    isOn: $twoFactorEnabled,
                    accentColor: themeManager.theme.accent
                )
                
                Divider().background(themeManager.theme.textPrimary.opacity(0.06)).padding(.leading, 56)
                
                SecurityToggleRow(
                    icon: "bell.badge.fill",
                    title: String.localized("security.auth.alerts.title"),
                    subtitle: String.localized("security.auth.alerts.desc"),
                    isOn: $loginAlerts,
                    accentColor: themeManager.theme.accent
                )
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
        }
    }
    
    // MARK: - Password Section
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: String.localized("security.section.password"))
            
            Button {
                showChangePassword = true
            } label: {
                HStack(spacing: 14) {
                    IconBadge(icon: "key.fill", color: themeManager.theme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String.localized("security.password.change_title"))
                            .font(.hBody)
                            .foregroundStyle(themeManager.theme.textPrimary)
                        
                        Text("\(String.localized("security.password.last_change")): 45 \(String.localized("common.time.days_ago"))")
                            .font(.hLabel)
                            .foregroundStyle(themeManager.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Sessions
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeader(title: String.localized("security.section.sessions"))
                Spacer()
                Button(String.localized("security.sessions.close_all")) { }
                    .font(.hLabel)
                    .foregroundStyle(themeManager.theme.accent)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(SessionItem.samples) { session in
                    HStack(spacing: 14) {
                        IconBadge(icon: session.icon, color: session.isCurrent ? themeManager.theme.accent : themeManager.theme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(session.device)
                                    .font(.hBody)
                                    .foregroundStyle(themeManager.theme.textPrimary)
                                
                                if session.isCurrent {
                                    Text(String.localized("security.sessions.current_device"))
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(themeManager.theme.textSecondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(themeManager.theme.accent.opacity(0.12)))
                                }
                            }
                            
                            Text("\(session.location) • \(session.isCurrent ? String.localized("security.sessions.active_now") : session.lastActive)")
                                .font(.hLabel)
                                .foregroundStyle(themeManager.theme.textPrimary)
                        }
                        
                        Spacer()
                        
                        if !session.isCurrent {
                            Button { } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(themeManager.theme.textPrimary.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    
                    if session.id != SessionItem.samples.last?.id {
                        Divider().background(themeManager.theme.textPrimary.opacity(0.06)).padding(.leading, 56)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: String.localized("security.section.danger_zone"))
                .foregroundStyle(themeManager.theme.accent)
            
            Button { } label: {
                HStack(spacing: 14) {
                    IconBadge(icon: "trash.fill", color: themeManager.theme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String.localized("security.danger.delete_title"))
                            .font(.hBody)
                            .foregroundStyle(themeManager.theme.accent)
                        
                        Text(String.localized("security.danger.delete_desc"))
                            .font(.hLabel)
                            .foregroundStyle(themeManager.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.theme.accent.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.theme.backgroundSecondary)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.theme.accent.opacity(0.15), lineWidth: 1))
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
    
    @Environment(ThemeManager.self) private var themeManager
    
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
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Text(subtitle)
                    .font(.hLabel)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: themeManager.theme.accent))
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

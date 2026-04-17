//
//  PrivacyPolicyView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    
    @State private var expandedSection: PrivacySection? = nil
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                lastUpdated
                
                ForEach(PrivacySection.allSections) { section in
                    privacySectionCard(section)
                }
                
                contactInfo
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("privacy.nav_title"))
                    .font(.hHeadline)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.textPrimary.opacity(0.12))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            
            VStack(spacing: 6) {
                Text(String.localized("privacy.header_title"))
                    .font(.hBodyMedium)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Text(String.localized("privacy.header_desc"))
                    .font(.hCaption)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.theme.backgroundSecondary)
        )
    }
    
    // MARK: - Last Updated
    private var lastUpdated: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 12))
            Text("\(String.localized("privacy.last_updated")): 1 Mart 2026")
                .font(.hLabel)
        }
        .foregroundStyle(themeManager.theme.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 4)
    }
    
    // MARK: - Section Card
    private func privacySectionCard(_ section: PrivacySection) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedSection = expandedSection == section ? nil : section
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(themeManager.theme.textSecondary.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: section.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(themeManager.theme.textSecondary)
                    }
                    
                    Text(section.title)
                        .font(.hBody)
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .rotationEffect(.degrees(expandedSection == section ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            
            if expandedSection == section {
                Divider()
                    .background(themeManager.theme.textPrimary.opacity(0.06))
                
                Text(section.content)
                    .font(.hCaption)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .lineSpacing(6)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.theme.backgroundSecondary)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Contact Info
    private var contactInfo: some View {
        VStack(spacing: 12) {
            Text(String.localized("privacy.contact_title"))
                .font(.hBodyMedium)
                .foregroundStyle(themeManager.theme.textPrimary)
            
            Text(String.localized("privacy.contact_desc"))
                .font(.hCaption)
                .foregroundStyle(themeManager.theme.textPrimary)
                .multilineTextAlignment(.center)
            
            Button {
                let email = "privacy@hissedar.com"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 13))
                    Text(String.localized("common.privacy.mail"))
                        .font(.hCaptionMed)
                }
                .foregroundStyle(themeManager.theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(themeManager.theme.textPrimary.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.theme.backgroundSecondary)
        )
    }
}

// MARK: - Privacy Section Model
struct PrivacySection: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let content: String
    
    static func == (lhs: PrivacySection, rhs: PrivacySection) -> Bool {
        lhs.id == rhs.id
    }
    
    static let allSections: [PrivacySection] = [
        PrivacySection(
            title: String.localized("privacy.section.data_collection.title"),
            icon: "doc.text.fill",
            content: String.localized("privacy.section.data_collection.content")
        ),
        PrivacySection(
            title: String.localized("privacy.section.usage.title"),
            icon: "gearshape.fill",
            content: String.localized("privacy.section.usage.content")
        ),
        PrivacySection(
            title: String.localized("privacy.section.security.title"),
            icon: "lock.shield.fill",
            content: String.localized("privacy.section.security.content")
        ),
        PrivacySection(
            title: String.localized("privacy.section.tracking.title"),
            icon: "eye.slash.fill",
            content: String.localized("privacy.section.tracking.content")
        ),
        PrivacySection(
            title: String.localized("privacy.section.rights.title"),
            icon: "person.crop.circle.badge.checkmark",
            content: String.localized("privacy.section.rights.content")
        ),
        PrivacySection(
            title: String.localized("privacy.section.compliance.title"),
            icon: "building.columns.fill",
            content: String.localized("privacy.section.compliance.content")
        ),
    ]
}

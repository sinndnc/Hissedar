//
//  SupportView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import SwiftUI

// MARK: - Support View
struct SupportView: View {
    
    @State private var expandedFAQ: FAQItem? = nil
    @State private var searchText = ""
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                supportHeader
                searchBar
                quickContactCards
                faqSection
                ticketSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("support.nav_title"))
                    .font(.hHeadline)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
    }
    
    // MARK: - Header
    private var supportHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.textPrimary.opacity(0.12))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            
            VStack(spacing: 4) {
                Text(String.localized("support.header.title"))
                    .font(.hBodyMedium)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Text(String.localized("support.header.subtitle"))
                    .font(.hCaption)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(themeManager.theme.textPrimary)
            
            TextField(String.localized("support.search_placeholder"), text: $searchText)
                .font(.hBody)
                .foregroundStyle(themeManager.theme.textPrimary)
                .tint(themeManager.theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(themeManager.theme.backgroundSecondary)
        )
    }
    
    // MARK: - Quick Contact
    private var quickContactCards: some View {
        HStack(spacing: 12) {
            SupportContactCard(
                icon: "bubble.left.and.bubble.right.fill",
                title: String.localized("support.contact.live.title"),
                subtitle: String.localized("support.contact.live.wait_time"),
                action: { /* Canlı destek başlat */ }
            )
            
            SupportContactCard(
                icon: "envelope.fill",
                title: String.localized("support.contact.email.title"),
                subtitle: String.localized("support.contact.email.wait_time"),
                action: { /* Mail taslağı aç */ }
            )
            
            SupportContactCard(
                icon: "phone.fill",
                title: String.localized("support.contact.phone.title"),
                subtitle: String.localized("support.contact.phone.hours"),
                action: { /* Telefonu ara */ }
            )
        }
    }
    
    // MARK: - FAQ
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String.localized("support.section.faq"))
            
            VStack(spacing: 0) {
                ForEach(FAQItem.samples) { faq in
                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                expandedFAQ = expandedFAQ == faq ? nil : faq
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(faq.question)
                                    .font(.hBody)
                                    .foregroundStyle(themeManager.theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(themeManager.theme.textPrimary)
                                    .rotationEffect(.degrees(expandedFAQ == faq ? 180 : 0))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        
                        if expandedFAQ == faq {
                            Text(faq.answer)
                                .font(.hCaption)
                                .foregroundStyle(themeManager.theme.textPrimary)
                                .lineSpacing(5)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    if faq.id != FAQItem.samples.last?.id {
                        Divider()
                            .background(themeManager.theme.textPrimary.opacity(0.06))
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Ticket
    private var ticketSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String.localized("support.section.tickets"))
            
            Button { } label: {
                HStack(spacing: 14) {
                    IconBadge(icon: "plus.message.fill", color: themeManager.theme.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(String.localized("support.tickets.create_new"))
                            .font(.hBody)
                            .foregroundStyle(themeManager.theme.textPrimary)
                        
                        Text(String.localized("support.tickets.create_desc"))
                            .font(.hLabel)
                            .foregroundStyle(themeManager.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 0) {
                ForEach(SupportTicket.samples) { ticket in
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ticket.title)
                                .font(.hBody)
                                .foregroundStyle(themeManager.theme.textPrimary)
                            
                            Text("\(ticket.id) • \(ticket.date)")
                                .font(.hLabel)
                                .foregroundStyle(themeManager.theme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Text(ticket.status)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(themeManager.theme.textPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(themeManager.theme.textPrimary.opacity(0.12)))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    
                    if ticket.id != SupportTicket.samples.last?.id {
                        Divider()
                            .background(themeManager.theme.textPrimary.opacity(0.06))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(themeManager.theme.backgroundSecondary))
        }
    }
}


// MARK: - Support Contact Card
struct SupportContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil // Aksiyonu dışarıdan alabilmek için eklendi
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 10) {
                // İkon alanı
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(themeManager.theme.accent)
                    .frame(height: 24)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.hLabel)
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8) // Uzun metinlerde taşmayı önler
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(themeManager.theme.textPrimary.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8) // Küçük ekranlarda metinlerin kenara yapışmaması için
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.theme.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.theme.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
struct FAQItem: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
    
    static func == (lhs: FAQItem, rhs: FAQItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static let samples: [FAQItem] = [
        FAQItem(
            question: String.localized("support.faq.q1.question"),
            answer: String.localized("support.faq.q1.answer")
        ),
        FAQItem(
            question: String.localized("support.faq.q2.question"),
            answer: String.localized("support.faq.q2.answer")
        ),
        FAQItem(
            question: String.localized("support.faq.q3.question"),
            answer: String.localized("support.faq.q3.answer")
        ),
        FAQItem(
            question: String.localized("support.faq.q4.question"),
            answer: String.localized("support.faq.q4.answer")
        ),
        FAQItem(
            question: String.localized("support.faq.q5.question"),
            answer: String.localized("support.faq.q5.answer")
        )
    ]
}

// MARK: - Ticket Model
struct SupportTicket: Identifiable {
    let id: String
    let title: String
    let date: String
    let status: String
    
    static let samples: [SupportTicket] = [
        SupportTicket(
            id: "#1042",
            title: String.localized("support.ticket.sample1.title"),
            date: "25 Mar",
            status: String.localized("support.ticket.status.in_progress")
        ),
        SupportTicket(
            id: "#1038",
            title: String.localized("support.ticket.sample2.title"),
            date: "20 Mar",
            status: String.localized("support.ticket.status.resolved")
        )
    ]
}

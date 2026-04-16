import SwiftUI

// MARK: - Support View
struct SupportView: View {
    
    @State private var expandedFAQ: FAQItem? = nil
    @State private var searchText = ""
    
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
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Destek")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Header
    private var supportHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.hJade.opacity(0.12))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.hJade)
            }
            
            VStack(spacing: 4) {
                Text("Nasıl yardımcı olabiliriz?")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                
                Text("7/24 destek ekibimiz yanınızda")
                    .font(.hCaption)
                    .foregroundStyle(Color.hsTextPrimary)
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
                .foregroundStyle(Color.hsTextPrimary)
            
            TextField("Sorunuzu arayın...", text: $searchText)
                .font(.hBody)
                .foregroundStyle(Color.hWhite)
                .tint(Color.hJade)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.hsBackgroundSecondary)
        )
    }
    
    // MARK: - Quick Contact
    private var quickContactCards: some View {
        HStack(spacing: 12) {
            SupportContactCard(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Canlı Destek",
                subtitle: "~2 dk",
                color: .hJade
            )
            
            SupportContactCard(
                icon: "envelope.fill",
                title: "E-posta",
                subtitle: "24 saat",
                color: .hGold
            )
            
            SupportContactCard(
                icon: "phone.fill",
                title: "Telefon",
                subtitle: "09-18",
                color: .hMint
            )
        }
    }
    
    // MARK: - FAQ
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sık Sorulan Sorular")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
                .padding(.leading, 4)
            
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
                                    .foregroundStyle(Color.hWhite)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.hsTextPrimary)
                                    .rotationEffect(.degrees(expandedFAQ == faq ? 180 : 0))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        
                        if expandedFAQ == faq {
                            Text(faq.answer)
                                .font(.hCaption)
                                .foregroundStyle(Color.hsTextPrimary)
                                .lineSpacing(5)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 14)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    if faq.id != FAQItem.samples.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Ticket
    private var ticketSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Destek Talebi")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
                .padding(.leading, 4)
            
            Button {
                // Create ticket
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.hJade.opacity(0.12))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "plus.message.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.hJade)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Yeni Talep Oluştur")
                            .font(.hBody)
                            .foregroundStyle(Color.hWhite)
                        
                        Text("Detaylı sorun bildirimi gönderin")
                            .font(.hLabel)
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.hsBackgroundSecondary)
                )
            }
            .buttonStyle(.plain)
            
            // Existing tickets
            VStack(spacing: 0) {
                ForEach(SupportTicket.samples) { ticket in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(ticket.statusColor)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ticket.title)
                                .font(.hBody)
                                .foregroundStyle(Color.hWhite)
                            
                            Text("\(ticket.id) • \(ticket.date)")
                                .font(.hLabel)
                                .foregroundStyle(Color.hsTextPrimary)
                        }
                        
                        Spacer()
                        
                        Text(ticket.status)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(ticket.statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(ticket.statusColor.opacity(0.12))
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    
                    if ticket.id != SupportTicket.samples.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 38)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
}

// MARK: - Contact Card
struct SupportContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button {
            // Action
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.hLabel)
                        .foregroundStyle(Color.hWhite)
                    
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.hsTextPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAQ Model
struct FAQItem: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
    
    static func == (lhs: FAQItem, rhs: FAQItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static let samples: [FAQItem] = [
        FAQItem(question: "Token nasıl satın alınır?", answer: "Bir varlık sayfasından 'Satın Al' butonuna tıklayarak istediğiniz miktarda token satın alabilirsiniz. Ödeme cüzdan bakiyenizden otomatik olarak düşülür."),
        FAQItem(question: "Kira gelirleri ne zaman dağıtılır?", answer: "Kira gelirleri her ayın 1'inde ve 15'inde otomatik olarak token sahiplerine dağıtılır. Gelir, sahip olduğunuz token oranında hesaplanır."),
        FAQItem(question: "Para çekme işlemi ne kadar sürer?", answer: "Banka havalesi ile para çekme işlemleri genellikle 1-3 iş günü içinde tamamlanır. IBAN bilgilerinizin doğru olduğundan emin olun."),
        FAQItem(question: "Minimum yatırım tutarı nedir?", answer: "Minimum yatırım tutarı varlığa göre değişmekle birlikte, genellikle ₺100'den başlamaktadır. Her varlığın minimum alım miktarını varlık detay sayfasında görebilirsiniz."),
        FAQItem(question: "Tokenlarımı başka birine transfer edebilir miyim?", answer: "Şu anda P2P token transferi desteklenmemektedir. Tokenlarınızı platform üzerinden satarak likidite sağlayabilirsiniz."),
    ]
}

// MARK: - Ticket Model
struct SupportTicket: Identifiable {
    let id: String
    let title: String
    let date: String
    let status: String
    let statusColor: Color
    
    static let samples: [SupportTicket] = [
        SupportTicket(id: "#1042", title: "Para çekme gecikmesi", date: "25 Mar", status: "İşlemde", statusColor: .hGold),
        SupportTicket(id: "#1038", title: "Kira geliri yansımadı", date: "20 Mar", status: "Çözüldü", statusColor: .hJade),
    ]
}

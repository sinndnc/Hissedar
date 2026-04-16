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
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Gizlilik Politikası")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.hJade.opacity(0.12))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.hJade)
            }
            
            VStack(spacing: 6) {
                Text("Verileriniz Güvende")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                
                Text("Hissedar olarak kişisel verilerinizin korunması en önemli önceliğimizdir.")
                    .font(.hCaption)
                    .foregroundStyle(Color.hsTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
        )
    }
    
    // MARK: - Last Updated
    private var lastUpdated: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 12))
            Text("Son güncelleme: 1 Mart 2026")
                .font(.hLabel)
        }
        .foregroundStyle(Color.hsTextPrimary)
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
                            .fill(section.color.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: section.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(section.color)
                    }
                    
                    Text(section.title)
                        .font(.hBody)
                        .foregroundStyle(Color.hWhite)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .rotationEffect(.degrees(expandedSection == section ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            
            if expandedSection == section {
                Divider()
                    .background(Color.hWhite.opacity(0.06))
                
                Text(section.content)
                    .font(.hCaption)
                    .foregroundStyle(Color.hsTextPrimary)
                    .lineSpacing(6)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.hsBackgroundSecondary)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Contact Info
    private var contactInfo: some View {
        VStack(spacing: 12) {
            Text("Sorularınız mı var?")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
            
            Text("Gizlilik politikamızla ilgili sorularınız için bize ulaşın.")
                .font(.hCaption)
                .foregroundStyle(Color.hsTextPrimary)
                .multilineTextAlignment(.center)
            
            Button {
                // Open email
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 13))
                    Text("privacy@hissedar.com")
                        .font(.hCaptionMed)
                }
                .foregroundStyle(Color.hJade)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.hJade.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
        )
    }
}

// MARK: - Privacy Section Model
struct PrivacySection: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let content: String
    
    static func == (lhs: PrivacySection, rhs: PrivacySection) -> Bool {
        lhs.id == rhs.id
    }
    
    static let allSections: [PrivacySection] = [
        PrivacySection(
            title: "Toplanan Veriler",
            icon: "doc.text.fill",
            color: .hJade,
            content: "Hissedar, hizmetlerimizi sunmak için ad-soyad, e-posta, telefon numarası, TC kimlik numarası ve adres bilgilerinizi toplar. Finansal işlemler için banka hesap bilgileriniz ve yatırım geçmişiniz de saklanır. Tüm veriler KVKK kapsamında işlenir."
        ),
        PrivacySection(
            title: "Veri Kullanımı",
            icon: "gearshape.fill",
            color: .hGold,
            content: "Topladığımız veriler yalnızca hizmet sunumu, yasal yükümlülükler, güvenlik doğrulaması ve hizmet iyileştirmeleri için kullanılır. Verileriniz hiçbir koşulda üçüncü taraflarla pazarlama amacıyla paylaşılmaz."
        ),
        PrivacySection(
            title: "Veri Güvenliği",
            icon: "lock.shield.fill",
            color: .hMint,
            content: "AES-256 şifreleme, TLS 1.3 iletişim protokolü ve çok katmanlı güvenlik altyapısı kullanılır. Finansal veriler banka seviyesi güvenlik standartlarında korunur. Düzenli güvenlik denetimleri gerçekleştirilir."
        ),
        PrivacySection(
            title: "Çerezler ve İzleme",
            icon: "eye.slash.fill",
            color: .hSilver,
            content: "Uygulama deneyimini iyileştirmek için analitik araçlar kullanılır. Çerezler yalnızca oturum yönetimi ve kullanıcı tercihlerini hatırlamak amacıyla kullanılır. Üçüncü taraf izleme çerezleri kullanılmaz."
        ),
        PrivacySection(
            title: "Haklarınız",
            icon: "person.crop.circle.badge.checkmark",
            color: .hJade,
            content: "KVKK kapsamında verilerinize erişim, düzeltme, silme ve taşıma haklarınız bulunmaktadır. Bu haklarınızı kullanmak için uygulama içinden veya privacy@hissedar.com adresinden bize ulaşabilirsiniz."
        ),
        PrivacySection(
            title: "SPK Uyumluluğu",
            icon: "building.columns.fill",
            color: .hGold,
            content: "Hissedar, Sermaye Piyasası Kurulu düzenlemelerine tam uyumlu şekilde faaliyet gösterir. Yatırımcı bilgileri SPK mevzuatı gereği belirlenen süre boyunca saklanır ve denetim otoritelerine gerektiğinde sunulur."
        ),
    ]
}

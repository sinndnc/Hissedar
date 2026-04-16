import SwiftUI

struct PropertyMapCardView: View {
    let item: AssetItem
    let onClose: () -> Void
    
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var lastOffset: CGFloat = 0
    @State private var isFullyClosed: Bool = false
    
    private let screenHeight = UIScreen.main.bounds.height
    private let expandedOffset: CGFloat = 60
    private let collapsedOffset: CGFloat = UIScreen.main.bounds.height * 0.6
    private let dismissThreshold: CGFloat = UIScreen.main.bounds.height * 0.8 // Kapanma eşiği
    
    var body: some View {
        ZStack(alignment: .top) {
            if !isFullyClosed { // İçerik kontrolü
                VStack(spacing: 0) {
                    // MARK: - Drag Handle (Sürükleme Alanı)
                    // Bu alan her zaman sürüklemeyi tetikler, scrollView ile çakışmaz
                    VStack {
                        Capsule()
                            .fill(Color.hsTextSecondary.opacity(0.3))
                            .frame(width: 36, height: 5)
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(Color.hsBackground)
                    .gesture(dragGesture) // Özel sürükleme alanı
                    
                    // MARK: - Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headerSection
                            statsSection
                            fundingSection
                            
                            Text("Mülk Detayları").font(.headline)
                            Text("Burada mülk ile ilgili detaylı açıklamalar yer alacak...").foregroundStyle(.secondary)
                            
                            Spacer(minLength: 150)
                        }
                        .padding(20)
                    }
                    // ScrollView sadece kart en tepedeyken çalışsın
                    .scrollDisabled(offset > expandedOffset + 10)
                }
                .frame(height: screenHeight - expandedOffset)
                .background(Color.hsBackground)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
                .offset(y: offset)
                .gesture(dragGesture)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = collapsedOffset
                lastOffset = collapsedOffset
            }
        }
    }
    
    // MARK: - Gesture Logic
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let newOffset = lastOffset + value.translation.height
                if newOffset < expandedOffset {
                    offset = expandedOffset + (value.translation.height / 3)
                } else {
                    offset = newOffset
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.height
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                    if velocity > 300 || offset > dismissThreshold {
                        // Kapanma animasyonunu başlat
                        offset = screenHeight
                        // Animasyonun bitmesini bekle ve üst view'ı bilgilendir
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            isFullyClosed = true
                            onClose()
                        }
                    } else if offset < (collapsedOffset + expandedOffset) / 2 || velocity < -200 {
                        offset = expandedOffset
                    } else {
                        offset = collapsedOffset
                    }
                    lastOffset = offset
                }
            }
    }
    
    // MARK: - Subviews (Kısa tutmak için)
    private var headerSection: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.hsBackgroundSecondary.overlay { Image(systemName: item.icon) }
                }
            }
            .frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading) {
                Text(item.title).font(.headline)
                Label(item.propertyCity ?? "", systemImage: "mappin").font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading) {
                Text("Token Fiyatı").font(.caption).foregroundStyle(.secondary)
                Text(item.formattedPrice).font(.headline)
            }
            VStack(alignment: .leading) {
                Text("Yıllık Getiri").font(.caption).foregroundStyle(.secondary)
                Text("%\(String(format: "%.1f", item.annualYieldPercent))").font(.headline).foregroundStyle(Color.hsAccent)
            }
        }
    }

    private var fundingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: min(item.fundingPercent / 100, 1.0))
                .tint(Color.hsAccent)
            Text("%\(Int(item.fundingPercent)) fonlandı").font(.caption).foregroundStyle(.secondary)
        }
    }
}

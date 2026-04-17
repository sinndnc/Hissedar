import SwiftUI
import Combine

// MARK: - KYC Status
enum KYCStatus: String, Codable {
    case notStarted = "not_started"
    case pending = "pending"
    case verified = "verified"
    case rejected = "rejected"
    
    var displayTitle: String {
        switch self {
        case .notStarted: return "Doğrulama Gerekli"
        case .pending: return "İnceleniyor"
        case .verified: return "Doğrulandı"
        case .rejected: return "Reddedildi"
        }
    }
    
    var color: Color {
        switch self {
        case .notStarted: return .hsTextPrimary
        case .pending: return .yellow
        case .verified: return .hsSuccess
        case .rejected: return .hsError
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "person.badge.clock"
        case .pending: return "hourglass"
        case .verified: return "checkmark.seal.fill"
        case .rejected: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Profile ViewModel
@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var tcNo: String = ""
    @Published var iban: String = ""
    @Published var kycStatus: KYCStatus = .notStarted
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var saveSuccess = false
    
    // Original values for change tracking
    private var originalFullName = ""
    private var originalEmail = ""
    private var originalPhone = ""
    private var originalIBAN = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var initials: String? {
        let parts = fullName.split(separator: " ")
        guard !parts.isEmpty else { return nil }
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
    
    var maskedTCNo: String {
        guard tcNo.count == 11 else { return tcNo }
        let lastFour = tcNo.suffix(4)
        return "•••••••\(lastFour)"
    }
    
    var maskedIBAN: String {
        guard iban.count >= 6 else { return iban }
        let prefix = iban.prefix(4)
        let suffix = iban.suffix(2)
        return "\(prefix) •••• •••• •••• •••• \(suffix)"
    }
    
    var hasChanges: Bool {
        fullName != originalFullName ||
        email != originalEmail ||
        phone != originalPhone ||
        iban != originalIBAN
    }
    
    // MARK: - Load Profile
    func loadProfile() {
        // TODO: Supabase'den kullanıcı profilini çek
        // Geçici mock data
        fullName = "Sinan Yılmaz"
        email = "sinan@hissedar.com"
        phone = "+90 555 123 4567"
        tcNo = "12345674589"
        iban = "TR330006100519786457841278"
        kycStatus = .verified
        
        // Store originals
        originalFullName = fullName
        originalEmail = email
        originalPhone = phone
        originalIBAN = iban
    }
    
    // MARK: - Save Profile
    func saveProfile() {
        guard hasChanges else { return }
        isSaving = true
        saveError = nil
        
        // TODO: Supabase update
        // try await supabase.from("users")
        //     .update([
        //         "full_name": fullName,
        //         "email": email,
        //         "phone": phone,
        //         "iban": iban
        //     ])
        //     .eq("id", value: currentUserId)
        //     .execute()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            self.isSaving = false
            self.saveSuccess = true
            
            // Update originals
            self.originalFullName = self.fullName
            self.originalEmail = self.email
            self.originalPhone = self.phone
            self.originalIBAN = self.iban
            
            // Reset success after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.saveSuccess = false
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        // TODO: Supabase auth sign out
        // try await supabase.auth.signOut()
    }
}

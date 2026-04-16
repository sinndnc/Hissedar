//
//  BaseViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/24/26.
//


import Foundation
import SwiftUI
import Combine
 
@Observable
@MainActor
class BaseViewModel {
    var isLoading     = false
    var errorMessage:   String?
    var successMessage: String?
    
    /// Loading guard + defer birleştirme yardımcısı.
    /// Kullanım:  await run { try await ... }
    func run(_ block: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await block()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func runSilently(_ block: () async throws -> Void) async {
        do { try await block() }
        catch { errorMessage = error.localizedDescription }
    }
}

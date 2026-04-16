//
//  CreatePriceAlertSheet.swift
//  Hissedar
//
//  Mülk detay sayfasından açılan alarm kurma sheet'i.
//

import SwiftUI

struct CreatePriceAlertSheet: View {

    // Mülk bilgileri
    let property: Property

    // Başarılı oluşturma sonrası çağrılacak callback
    var onCreated: (() -> Void)? = nil

    @StateObject private var vm = PriceAlertsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Mevcut Fiyat Bilgisi
                Section {
                    HStack {
                        Text("Mevcut token fiyatı")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(property.tokenPrice.tlFormatted)
                            .font(.headline)
                    }
                }

                // MARK: - Koşul Tipi
                Section("Alarm koşulu") {
                    Picker("Koşul", selection: $vm.selectedCondition) {
                        ForEach(PriceAlertCondition.allCases) { condition in
                            Label(condition.shortLabel, systemImage: condition.systemIcon)
                                .tag(condition)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Koşul Parametreleri
                Section {
                    conditionParametersView
                } header: {
                    Text(conditionHeaderText)
                } footer: {
                    Text(conditionFooterText)
                        .font(.caption)
                }

                // MARK: - Davranış
                Section("Davranış") {
                    Picker("Davranış", selection: $vm.behavior) {
                        ForEach(PriceAlertBehavior.allCases) { behavior in
                            Text(behavior.displayName).tag(behavior)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(vm.behavior.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Hata Mesajı
                if let err = vm.formErrorMessage {
                    Section {
                        Label(err, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Fiyat Alarmı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if vm.isCreatingAlert {
                            ProgressView()
                        } else {
                            Text("Oluştur").fontWeight(.semibold)
                        }
                    }
                    .disabled(vm.isCreatingAlert)
                }
            }
        }
    }

    // MARK: - Koşul Parametreleri (değişken içerik)

    @ViewBuilder
    private var conditionParametersView: some View {
        switch vm.selectedCondition {
        case .below, .above:
            HStack {
                Text("Hedef fiyat")
                Spacer()
                TextField("0", text: $vm.targetPriceInput)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 140)
                Text("₺")
                    .foregroundStyle(.secondary)
            }

        case .percentChange:
            Picker("Yön", selection: $vm.percentDirection) {
                ForEach(PriceAlertsViewModel.PercentDirection.allCases) { dir in
                    Text(dir.displayName).tag(dir)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Yüzde")
                Spacer()
                TextField("0", text: $vm.percentInput)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 100)
                Text("%")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var conditionHeaderText: String {
        switch vm.selectedCondition {
        case .below:         return "Altına düşme alarmı"
        case .above:         return "Üstüne çıkma alarmı"
        case .percentChange: return "Yüzde değişim alarmı"
        }
    }

    private var conditionFooterText: String {
        switch vm.selectedCondition {
        case .below:
            return "Token fiyatı bu değerin altına düştüğünde bildirim alırsınız."
        case .above:
            return "Token fiyatı bu değerin üstüne çıktığında bildirim alırsınız."
        case .percentChange:
            return "Şu anki fiyat (\(property.tokenPrice.tlFormatted)) baz alınır. Fiyat bu orandan fazla \(vm.percentDirection.displayName.lowercased()) bildirim alırsınız."
        }
    }

    // MARK: - Submit

    private func submit() async {
        guard let userId = AppState.shared.currentUser?.id else {
            vm.formErrorMessage = "Oturum bilgisi bulunamadı"
            return
        }

        let success = await vm.createAlert(
            userId: userId,
            propertyId: property.id,
            currentPrice: property.tokenPrice
        )

        if success {
            onCreated?()
            dismiss()
        }
    }
}
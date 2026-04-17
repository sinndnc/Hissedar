//
//  CreatePriceAlertSheet.swift
//  Hissedar
//
//  Alarm kurma sheet — AssetDetail veya AssetItem ile kullanılabilir.
//

import SwiftUI
import Factory

// MARK: - Alert Source

/// CreatePriceAlertSheet'in ihtiyaç duyduğu minimum asset bilgisi.
/// Hem AssetDetail hem AssetItem bu protokole uyar.
protocol PriceAlertSource {
    var id: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var assetType: AssetType { get }
    var currentValue: Decimal { get }
}

extension AssetDetail: PriceAlertSource {}
extension AssetItem:   PriceAlertSource {}

// MARK: - Sheet

struct CreatePriceAlertSheet: View {
    var asset: PriceAlertSource
    var onCreated: (() -> Void)? = nil
    
    var appState: AppState = Container.shared.appState()
    @StateObject private var vm = PriceAlertsViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    conditionCard
                    parametersCard
                    behaviorCard
                    
                    if let err = vm.formErrorMessage {
                        errorView(err)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(themeManager.theme.background)
            .navigationTitle(String.localized("alert.create.nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String.localized("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if vm.isCreatingAlert {
                            ProgressView()
                        } else {
                            Text(String.localized("common.create")).fontWeight(.semibold)
                        }
                    }
                    .disabled(vm.isCreatingAlert)
                }
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: asset.assetType.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(asset.assetType.accentColor)
                    .frame(width: 40, height: 40)
                    .background(asset.assetType.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .lineLimit(1)
                    if let subtitle = asset.subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(themeManager.theme.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }

            Divider()

            HStack {
                Text(String.localized("alert.create.current_price"))
                    .font(.system(size: 13))
                    .foregroundStyle(themeManager.theme.textSecondary)
                Spacer()
                Text(asset.currentValue.tlFormatted)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
        .padding(16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }

    // MARK: - Koşul

    private var conditionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(String.localized("alert.create.condition_label"), icon: "slider.horizontal.3")

            Picker("", selection: $vm.selectedCondition) {
                ForEach(PriceAlertCondition.allCases) { cond in
                    Text(cond.shortLabel).tag(cond)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }

    // MARK: - Parametreler

    private var parametersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(parametersHeader, icon: vm.selectedCondition.systemIcon)

            switch vm.selectedCondition {
            case .below, .above:
                priceInputRow

            case .percentChange:
                Picker("", selection: $vm.percentDirection) {
                    ForEach(PriceAlertsViewModel.PercentDirection.allCases) { d in
                        Text(d.displayName).tag(d)
                    }
                }
                .pickerStyle(.segmented)

                percentInputRow
            }

            Text(parametersFooter)
                .font(.system(size: 11))
                .foregroundStyle(themeManager.theme.textSecondary)
                .padding(.top, 4)
        }
        .padding(16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }

    private var priceInputRow: some View {
        HStack(spacing: 8) {
            TextField("0", text: $vm.targetPriceInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .padding(12)
                .background(themeManager.theme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("₺")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
    }

    private var percentInputRow: some View {
        HStack(spacing: 8) {
            TextField("0", text: $vm.percentInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .padding(12)
                .background(themeManager.theme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("%")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
    }

    private var parametersHeader: String {
        switch vm.selectedCondition {
        case .below:         return String.localized("alert.create.header.below")
        case .above:         return String.localized("alert.create.header.above")
        case .percentChange: return String.localized("alert.create.header.percent")
        }
    }

    private var parametersFooter: String {
        switch vm.selectedCondition {
        case .below:
            return String.localized("alert.create.footer.below")
        case .above:
            return String.localized("alert.create.footer.above")
        case .percentChange:
            let price = asset.currentValue.tlFormatted
            let direction = vm.percentDirection.displayName.lowercased()
            return String(format: String.localized("alert.create.footer.percent"), price, direction)
        }
    }

    // MARK: - Davranış

    private var behaviorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(String.localized("alert.create.behavior_label"), icon: "arrow.triangle.2.circlepath")

            Picker("", selection: $vm.behavior) {
                ForEach(PriceAlertBehavior.allCases) { b in
                    Text(b.displayName).tag(b)
                }
            }
            .pickerStyle(.segmented)

            Text(vm.behavior.description)
                .font(.system(size: 11))
                .foregroundStyle(themeManager.theme.textSecondary)
                .padding(.top, 4)
        }
        .padding(16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }

    // MARK: - Error

    private func errorView(_ msg: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
            Text(msg)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(themeManager.theme.error)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(themeManager.theme.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(themeManager.theme.accent)
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
        }
    }

    private func submit() async {
        guard let userId = appState.currentUser?.id else {
            vm.formErrorMessage = String.localized("auth.error.session_not_found")
            return
        }

        let success = await vm.createAlert(
            userId: userId,
            assetId: asset.id,
            assetType: asset.assetType,
            currentPrice: asset.currentValue
        )

        if success {
            onCreated?()
            dismiss()
        }
    }
}

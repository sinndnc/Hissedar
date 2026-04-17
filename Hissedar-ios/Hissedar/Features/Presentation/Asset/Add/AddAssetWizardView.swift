//
//  AddAssetWizardView.swift
//  Hissedar
//

import SwiftUI

struct AddAssetWizardView: View {
    
    @State private var viewModel = AddAssetViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(spacing: 0) {
            stepIndicator
            
            Divider()
            
            TabView(selection: $viewModel.currentStep) {
                AddAssetStep1View(viewModel: viewModel).tag(AddAssetStep.generalInfo)
                AddAssetStep2View(viewModel: viewModel).tag(AddAssetStep.assetType)
                AddAssetStep3View(viewModel: viewModel).tag(AddAssetStep.typeDetails)
                AddAssetStep4View(viewModel: viewModel).tag(AddAssetStep.preview)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            
            Divider()
            
            bottomNavigation
        }
        .navigationTitle(String.localized("wizard.nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(String.localized("common.success"), isPresented: $viewModel.submitSuccess) {
            Button(String.localized("common.ok")) { dismiss() }
        } message: {
            Text(String.localized("wizard.success.message"))
        }
    }
    
    private var stepIndicator: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 4)
                    Capsule().fill(Color.accentColor).frame(width: geo.size.width * viewModel.stepProgress, height: 4)
                }
            }
            .frame(height: 4).padding(.horizontal)
            
            HStack(spacing: 0) {
                ForEach(AddAssetStep.allCases, id: \.self) { step in
                    stepDot(for: step)
                    if step != AddAssetStep.allCases.last { Spacer() }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 16).background(themeManager.theme.background)
    }

    private func stepDot(for step: AddAssetStep) -> some View {
        let isCompleted = step.rawValue < viewModel.currentStep.rawValue
        let isCurrent = step == viewModel.currentStep
        return VStack(spacing: 6) {
            ZStack {
                Circle().fill(isCompleted ? Color.accentColor : (isCurrent ? Color.accentColor.opacity(0.15) : Color(.systemGray5))).frame(width: 32, height: 32)
                if isCompleted { Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.white) }
                else { Text("\(step.stepNumber)").font(.system(size: 13, weight: .semibold)).foregroundStyle(isCurrent ? Color.accentColor : .secondary) }
            }
            Text(step.title).font(.system(size: 10)).foregroundStyle(isCurrent ? .primary : .secondary)
        }
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 12) {
            if !viewModel.isFirstStep {
                Button { viewModel.goBack() } label: {
                    Text(String.localized("common.back")).font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.accentColor).frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.accentColor.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Button {
                if viewModel.isLastStep { Task { await viewModel.submit() } }
                else { viewModel.goNext() }
            } label: {
                HStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    else { Text(viewModel.isLastStep ? String.localized("wizard.action.publish") : String.localized("common.continue")) }
                }
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 50)
                .background(viewModel.canGoNext ? Color.accentColor : Color(.systemGray4)).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canGoNext || viewModel.isLoading)
        }
        .padding(.horizontal).padding(.vertical, 12).background(Color(.systemBackground))
    }
}

//
//  AddAssetWizardView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct AddAssetWizardView: View {
    
    @State private var viewModel = AddAssetViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            stepIndicator
            
            Divider()
            
            TabView(selection: $viewModel.currentStep) {
                AddAssetStep1View(viewModel: viewModel)
                    .tag(AddAssetStep.generalInfo)
                
                AddAssetStep2View(viewModel: viewModel)
                    .tag(AddAssetStep.assetType)
                
                AddAssetStep3View(viewModel: viewModel)
                    .tag(AddAssetStep.typeDetails)
                
                AddAssetStep4View(viewModel: viewModel)
                    .tag(AddAssetStep.preview)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            
            Divider()
            
            bottomNavigation
        }
        .navigationTitle("Varlık Ekle")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Başarılı", isPresented: $viewModel.submitSuccess) {
            Button("Tamam") {
                dismiss()
            }
        } message: {
            Text("Varlık başarıyla eklendi. İnceleme sonrasında yayınlanacaktır.")
        }
        .alert("Hata", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Step Indicator
    
    private var stepIndicator: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * viewModel.stepProgress, height: 4)
                        .animation(.easeInOut(duration: 0.4), value: viewModel.stepProgress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            
            // Step dots with labels
            HStack(spacing: 0) {
                ForEach(AddAssetStep.allCases, id: \.self) { step in
                    stepDot(for: step)
                    if step != AddAssetStep.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private func stepDot(for step: AddAssetStep) -> some View {
        let isCompleted = step.rawValue < viewModel.currentStep.rawValue
        let isCurrent = step == viewModel.currentStep
        
        return Button {
            viewModel.goToStep(step)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.accentColor : (isCurrent ? Color.accentColor.opacity(0.15) : Color(.systemGray5)))
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.stepNumber)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isCurrent ? Color.accentColor : .secondary)
                    }
                }
                
                Text(step.title)
                    .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                    .foregroundStyle(isCurrent ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .disabled(step.rawValue > viewModel.currentStep.rawValue)
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        HStack(spacing: 12) {
            if !viewModel.isFirstStep {
                Button {
                    viewModel.goBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Geri")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Button {
                if viewModel.isLastStep {
                    Task { await viewModel.submit() }
                } else {
                    viewModel.goNext()
                }
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(viewModel.isLastStep ? "İlanı Yayınla" : "Devam Et")
                        if !viewModel.isLastStep {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canGoNext ? Color.accentColor : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canGoNext || viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    AddAssetWizardView()
}

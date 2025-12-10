//
//  TutorialScreens.swift
//  ConnectoSphere
//
//

import SwiftUI

struct TutorialScreens: View {
    @Binding var currentStep: OnboardingStep
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, description: String)] = [
        ("circle.hexagongrid.circle.fill", AppStrings.tutorialStep1Title, AppStrings.tutorialStep1Description),
        ("message.badge.fill", AppStrings.tutorialStep2Title, AppStrings.tutorialStep2Description),
        ("person.2.circle.fill", AppStrings.tutorialStep3Title, AppStrings.tutorialStep3Description)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.secondaryBackground, AppColors.tertiaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep = .privacy
                        }
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                }
                
                Spacer()
                
                // Tutorial content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 100))
                                .foregroundStyle(AppColors.accentGreen)
                                .shadow(color: .black.opacity(0.3), radius: 10)
                            
                            Text(pages[index].title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(pages[index].description)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                // Next/Continue button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep = .privacy
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(AppColors.accentGreen)
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(AppColors.glassOverlay)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(AppColors.glassBorder, lineWidth: 1)
                        )
                        .shadow(color: AppColors.accentGreen.opacity(0.5), radius: 10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}


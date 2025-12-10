//
//  WelcomeScreen.swift
//  ConnectoSphere
//
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.primaryBackground, AppColors.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon/Logo
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppColors.accentGreen)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                
                VStack(spacing: 15) {
                    Text(AppStrings.welcomeTitle)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(AppStrings.welcomeSubtitle)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                Text(AppStrings.welcomeDescription)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep = .tutorial
                    }
                }) {
                    Text("Get Started")
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

enum OnboardingStep {
    case welcome
    case tutorial
    case auth
    case privacy
}


//
//  PrivacyScreen.swift
//  ConnectoSphere
//
//

import SwiftUI

struct PrivacyScreen: View {
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryBackground, AppColors.tertiaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppColors.accentGreen)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                
                VStack(spacing: 15) {
                    Text(AppStrings.privacyTitle)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(AppStrings.privacyDescription)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    PrivacyFeatureRow(icon: "eye.slash.fill", text: "Control who sees your profile")
                    PrivacyFeatureRow(icon: "hand.raised.fill", text: "Your data stays on your device")
                    PrivacyFeatureRow(icon: "checkmark.shield.fill", text: "Delete your account anytime")
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep = .auth
                    }
                }) {
                    Text("I Understand")
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

struct PrivacyFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.accentGreen)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.white)
        }
    }
}


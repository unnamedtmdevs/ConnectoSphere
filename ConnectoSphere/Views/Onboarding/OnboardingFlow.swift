//
//  OnboardingFlow.swift
//  ConnectoSphere
//
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentStep: OnboardingStep = .welcome
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeScreen(currentStep: $currentStep)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .tutorial:
                TutorialScreens(currentStep: $currentStep)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .privacy:
                PrivacyScreen(currentStep: $currentStep)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .auth:
                AuthScreen()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
}


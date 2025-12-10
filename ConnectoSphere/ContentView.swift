//
//  ContentView.swift
//  ConnectoSphere
//
import SwiftUI

struct ContentView: View {
    @ObservedObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.hasCompletedOnboarding && authService.currentUser != nil {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
        .preferredColorScheme(nil) // Support both light and dark mode
    }
}

#Preview {
    ContentView()
}

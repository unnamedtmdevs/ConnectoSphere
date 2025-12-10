//
//  ContentView.swift
//  ConnectoSphere
//
import SwiftUI

struct ContentView: View {
    @ObservedObject private var authService = AuthService.shared
    @StateObject private var serverCheckService = ServerCheckService()
    
    var body: some View {
        ZStack {
            // Показываем ProgressView пока идет проверка сервера
            if !serverCheckService.isFetched {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                // После проверки показываем либо WebView, либо обычное приложение
                if serverCheckService.isBlock {
                    // Показываем обычное приложение ConnectoSphere
                    Group {
                        if authService.hasCompletedOnboarding && authService.currentUser != nil {
                            MainTabView()
                        } else {
                            OnboardingFlow()
                        }
                    }
                    .preferredColorScheme(nil) // Support both light and dark mode
                } else {
                    // Показываем WebView
                    WebSystem()
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            // Проверяем сервер при запуске приложения
            serverCheckService.makeServerRequest()
        }
    }
}

#Preview {
    ContentView()
}

//
//  ConnectoSphereApp.swift
//  ConnectoSphere
//
import SwiftUI
import FirebaseCore

@main
struct ConnectoSphereApp: App {
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
        print("🔥 Firebase initialized")
    }
    
    // Initialize services
    @StateObject private var authService = AuthService.shared
    @StateObject private var dataService = DataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(dataService)
        }
    }
}

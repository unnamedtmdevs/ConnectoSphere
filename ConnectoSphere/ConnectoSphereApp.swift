//
//  ConnectoSphereApp.swift
//  ConnectoSphere
//

import SwiftUI

@main
struct ConnectoSphereApp: App {
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

//
//  AuthService.swift
//  ConnectoSphere
//
//
import Foundation
import SwiftUI
import Combine

// Wrapper для совместимости со старым кодом
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let firebaseAuth = FirebaseAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentUserID: String = ""
    @Published var currentUser: User?
    
    init() {
        // Синхронизируем с Firebase Auth Service через Combine
        firebaseAuth.$hasCompletedOnboarding
            .assign(to: \.hasCompletedOnboarding, on: self)
            .store(in: &cancellables)
        
        firebaseAuth.$currentUserID
            .assign(to: \.currentUserID, on: self)
            .store(in: &cancellables)
        
        firebaseAuth.$currentUser
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
    }
    
    func signUpWithEmail(username: String, email: String) {
        // Для простоты используем username как пароль (можно улучшить)
        let password = "ConnectoSphere_\(username)_2024"
        firebaseAuth.signUpWithEmail(username: username, email: email, password: password) { success in
            if !success {
                print("❌ Sign up failed")
            }
        }
    }
    
    func continueAsGuest() {
        firebaseAuth.signInAnonymously(username: "Guest_\(UUID().uuidString.prefix(8))") { success in
            if !success {
                print("❌ Guest sign in failed")
            }
        }
    }
    
    func logout() {
        firebaseAuth.logout()
    }
    
    func deleteAccount() {
        firebaseAuth.deleteAccount { success in
            if !success {
                print("❌ Account deletion failed")
            }
        }
    }
}


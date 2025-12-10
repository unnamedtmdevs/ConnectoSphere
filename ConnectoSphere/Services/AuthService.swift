//
//  AuthService.swift
//  ConnectoSphere
//
//

import Foundation
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("currentUserID") var currentUserID: String = ""
    
    @Published var currentUser: User?
    
    private let dataService = DataService.shared
    
    init() {
        if !currentUserID.isEmpty {
            currentUser = dataService.getUser(byID: currentUserID)
        }
    }
    
    func signUpWithEmail(username: String, email: String) {
        let user = dataService.createUser(username: username, email: email)
        currentUser = user
        currentUserID = user.id
        hasCompletedOnboarding = true
    }
    
    func continueAsGuest() {
        let user = User.guest()
        dataService.users.append(user)
        currentUser = user
        currentUserID = user.id
        hasCompletedOnboarding = true
    }
    
    func logout() {
        currentUser = nil
        currentUserID = ""
        hasCompletedOnboarding = false
    }
    
    func deleteAccount() {
        dataService.clearAllData()
        currentUser = nil
        currentUserID = ""
        hasCompletedOnboarding = false
    }
}


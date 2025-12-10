//
//  ProfileViewModel.swift
//  ConnectoSphere
//
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var userPosts: [Post] = []
    @Published var userCircles: [Circle] = []
    
    private let dataService = DataService.shared
    private let authService = AuthService.shared
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        user = authService.currentUser
        guard let userID = user?.id else { return }
        
        userPosts = dataService.posts
            .filter { $0.authorID == userID }
            .sorted(by: { $0.createdAt > $1.createdAt })
        
        userCircles = dataService.getUserCircles(userID: userID)
    }
    
    func updateProfile(username: String, bio: String, theme: User.ProfileTheme, tags: [String]) {
        guard var user = user else { return }
        user.username = username
        user.bio = bio
        user.profileTheme = theme
        user.interestTags = tags
        
        dataService.updateUser(user)
        authService.currentUser = user
        self.user = user
    }
}


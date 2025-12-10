//
//  HomeViewModel.swift
//  ConnectoSphere
//
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var feedPosts: [Post] = []
    @Published var suggestedConnections: [Connection] = []
    @Published var isLoadingPosts = false
    
    private let dataService = DataService.shared
    private let connectionService = ConnectionService.shared
    private let authService = AuthService.shared
    
    init() {
        loadFeed()
        loadSuggestedConnections()
    }
    
    func loadFeed() {
        guard let userID = authService.currentUser?.id else { return }
        isLoadingPosts = true
        feedPosts = dataService.getFeedPosts(userID: userID)
        isLoadingPosts = false
    }
    
    func loadSuggestedConnections() {
        guard let userID = authService.currentUser?.id else { return }
        suggestedConnections = connectionService.suggestConnections(for: userID, limit: 5)
    }
    
    func toggleReaction(postID: String, type: ReactionType) {
        guard let userID = authService.currentUser?.id else { return }
        
        if let post = dataService.posts.first(where: { $0.id == postID }),
           post.reactions.contains(where: { $0.userID == userID && $0.type == type }) {
            dataService.removeReaction(postID: postID, userID: userID)
        } else {
            dataService.addReaction(postID: postID, userID: userID, type: type)
        }
        
        loadFeed()
    }
    
    func getUserReaction(for postID: String) -> ReactionType? {
        guard let userID = authService.currentUser?.id,
              let post = dataService.posts.first(where: { $0.id == postID }) else { return nil }
        
        return post.reactions.first(where: { $0.userID == userID })?.type
    }
}


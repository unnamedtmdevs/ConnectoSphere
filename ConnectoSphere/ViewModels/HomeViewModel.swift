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
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupRealtimeUpdates()
        loadFeed()
        loadSuggestedConnections()
    }
    
    private func setupRealtimeUpdates() {
        // Подписываемся на изменения posts и circles для автоматического обновления фида
        Publishers.CombineLatest3(
            dataService.$posts,
            dataService.$circles,
            authService.$currentUser
        )
        .map { [weak self] posts, circles, currentUser in
            guard let self = self, let userID = currentUser?.id else { return [] }
            let userCircleIDs = circles.filter { $0.memberIDs.contains(userID) }.map { $0.id }
            return posts
                .filter { userCircleIDs.contains($0.circleID) }
                .sorted(by: { $0.createdAt > $1.createdAt })
        }
        .assign(to: \.feedPosts, on: self)
        .store(in: &cancellables)
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
        // Автоматически обновится через Combine
    }
    
    func getUserReaction(for postID: String) -> ReactionType? {
        guard let userID = authService.currentUser?.id,
              let post = dataService.posts.first(where: { $0.id == postID }) else { return nil }
        
        return post.reactions.first(where: { $0.userID == userID })?.type
    }
}


//
//  CircleDetailViewModel.swift
//  ConnectoSphere
//
//

import Foundation
import Combine

class CircleDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:]
    
    let circle: Circle
    private let dataService = DataService.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(circle: Circle) {
        self.circle = circle
        setupRealtimeUpdates()
        loadPosts()
    }
    
    private func setupRealtimeUpdates() {
        // Подписываемся на изменения posts в DataService
        dataService.$posts
            .map { [weak self] allPosts in
                guard let self = self else { return [] }
                return allPosts.filter { $0.circleID == self.circle.id }
                    .sorted(by: { $0.createdAt > $1.createdAt })
            }
            .assign(to: \.posts, on: self)
            .store(in: &cancellables)
        
        // Подписываемся на изменения comments
        dataService.$comments
            .sink { [weak self] allComments in
                guard let self = self else { return }
                var newComments: [String: [Comment]] = [:]
                for post in self.posts {
                    newComments[post.id] = allComments.filter { $0.postID == post.id }
                        .sorted(by: { $0.createdAt < $1.createdAt })
                }
                self.comments = newComments
            }
            .store(in: &cancellables)
    }
    
    func loadPosts() {
        posts = dataService.getCirclePosts(circleID: circle.id)
        
        for post in posts {
            comments[post.id] = dataService.getPostComments(postID: post.id)
        }
    }
    
    func createPost(title: String, content: String) {
        guard let userID = authService.currentUser?.id else { return }
        _ = dataService.createPost(title: title, content: content, circleID: circle.id, authorID: userID)
        // loadPosts() больше не нужен - автоматически обновится через Combine
    }
    
    func addComment(postID: String, content: String) {
        guard let userID = authService.currentUser?.id else { return }
        _ = dataService.createComment(postID: postID, authorID: userID, content: content)
        // Автоматически обновится через Combine
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


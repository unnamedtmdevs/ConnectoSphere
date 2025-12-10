//
//  CircleDetailViewModel.swift
//  ConnectoSphere
//
//

import Foundation

class CircleDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:]
    
    let circle: Circle
    private let dataService = DataService.shared
    private let authService = AuthService.shared
    
    init(circle: Circle) {
        self.circle = circle
        loadPosts()
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
        loadPosts()
    }
    
    func addComment(postID: String, content: String) {
        guard let userID = authService.currentUser?.id else { return }
        _ = dataService.createComment(postID: postID, authorID: userID, content: content)
        loadPosts()
    }
    
    func toggleReaction(postID: String, type: ReactionType) {
        guard let userID = authService.currentUser?.id else { return }
        
        if let post = dataService.posts.first(where: { $0.id == postID }),
           post.reactions.contains(where: { $0.userID == userID && $0.type == type }) {
            dataService.removeReaction(postID: postID, userID: userID)
        } else {
            dataService.addReaction(postID: postID, userID: userID, type: type)
        }
        
        loadPosts()
    }
    
    func getUserReaction(for postID: String) -> ReactionType? {
        guard let userID = authService.currentUser?.id,
              let post = dataService.posts.first(where: { $0.id == postID }) else { return nil }
        
        return post.reactions.first(where: { $0.userID == userID })?.type
    }
}


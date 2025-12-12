//
//  DataService.swift
//  ConnectoSphere
//
//

import Foundation
import Combine

// Wrapper для совместимости со старым кодом
class DataService: ObservableObject {
    static let shared = DataService()
    
    private let firebaseData = FirebaseDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var users: [User] = []
    @Published var circles: [Circle] = []
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    
    private let usersKey = "connectosphere_users"
    private let circlesKey = "connectosphere_circles"
    private let postsKey = "connectosphere_posts"
    private let commentsKey = "connectosphere_comments"
    
    init() {
        // Синхронизируем с Firebase Data Service через Combine
        firebaseData.$circles
            .assign(to: \.circles, on: self)
            .store(in: &cancellables)
        
        firebaseData.$posts
            .assign(to: \.posts, on: self)
            .store(in: &cancellables)
        
        firebaseData.$comments
            .assign(to: \.comments, on: self)
            .store(in: &cancellables)
        
        firebaseData.$users
            .assign(to: \.users, on: self)
            .store(in: &cancellables)
        
        // Инициализируем default circles
        firebaseData.initializeDefaultCircles()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        users = loadFromStorage(key: usersKey) ?? []
        circles = loadFromStorage(key: circlesKey) ?? []
        posts = loadFromStorage(key: postsKey) ?? []
        comments = loadFromStorage(key: commentsKey) ?? []
    }
    
    private func saveData() {
        saveToStorage(users, key: usersKey)
        saveToStorage(circles, key: circlesKey)
        saveToStorage(posts, key: postsKey)
        saveToStorage(comments, key: commentsKey)
    }
    
    private func loadFromStorage<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func saveToStorage<T: Codable>(_ object: T, key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func clearAllData() {
        // Теперь управляется через Firebase
        // Данные очищаются через deleteAccount в FirebaseAuthService
    }
    
    // MARK: - User Management
    
    func createUser(username: String, email: String) -> User {
        let user = User(
            id: UUID().uuidString,
            username: username,
            email: email,
            bio: "",
            profileTheme: .minimal,
            interestTags: [],
            joinedCircleIDs: [],
            isGuest: false,
            createdAt: Date()
        )
        users.append(user)
        saveData()
        return user
    }
    
    func updateUser(_ user: User) {
        FirebaseAuthService.shared.updateUser(user) { _ in }
    }
    
    func getUser(byID id: String) -> User? {
        firebaseData.getUser(byID: id)
    }
    
    // MARK: - Circle Management
    
    func createCircle(name: String, description: String, category: String, tags: [String], creatorID: String) -> Circle {
        var circle: Circle?
        firebaseData.createCircle(name: name, description: description, category: category, tags: tags, creatorID: creatorID) { createdCircle in
            circle = createdCircle
        }
        return circle ?? Circle(id: UUID().uuidString, name: name, description: description, category: category, creatorID: creatorID, memberIDs: [creatorID], postIDs: [], createdAt: Date(), tags: tags)
    }
    
    func joinCircle(circleID: String, userID: String) {
        firebaseData.joinCircle(circleID: circleID, userID: userID) { success in
            if !success {
                print("❌ Failed to join circle")
            }
        }
    }
    
    func leaveCircle(circleID: String, userID: String) {
        firebaseData.leaveCircle(circleID: circleID, userID: userID) { success in
            if !success {
                print("❌ Failed to leave circle")
            }
        }
    }
    
    func getUserCircles(userID: String) -> [Circle] {
        firebaseData.getUserCircles(userID: userID)
    }
    
    // MARK: - Post Management
    
    func createPost(title: String, content: String, circleID: String, authorID: String) -> Post {
        var post: Post?
        firebaseData.createPost(title: title, content: content, circleID: circleID, authorID: authorID) { createdPost in
            post = createdPost
        }
        return post ?? Post(id: UUID().uuidString, authorID: authorID, circleID: circleID, content: content, title: title, reactions: [], commentIDs: [], createdAt: Date())
    }
    
    func addReaction(postID: String, userID: String, type: ReactionType) {
        firebaseData.addReaction(postID: postID, userID: userID, type: type) { _ in }
    }
    
    func removeReaction(postID: String, userID: String) {
        firebaseData.removeReaction(postID: postID, userID: userID) { _ in }
    }
    
    func getCirclePosts(circleID: String) -> [Post] {
        firebaseData.getCirclePosts(circleID: circleID)
    }
    
    func getFeedPosts(userID: String) -> [Post] {
        firebaseData.getFeedPosts(userID: userID)
    }
    
    // MARK: - Comment Management
    
    func createComment(postID: String, authorID: String, content: String) -> Comment {
        var comment: Comment?
        firebaseData.createComment(postID: postID, authorID: authorID, content: content) { createdComment in
            comment = createdComment
        }
        return comment ?? Comment(id: UUID().uuidString, authorID: authorID, postID: postID, content: content, createdAt: Date())
    }
    
    func getPostComments(postID: String) -> [Comment] {
        firebaseData.getPostComments(postID: postID)
    }
    
    // MARK: - Default Data
    
    // Удалено - теперь используется Firebase
}


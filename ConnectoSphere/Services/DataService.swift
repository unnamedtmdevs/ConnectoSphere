//
//  DataService.swift
//  ConnectoSphere
//
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var users: [User] = []
    @Published var circles: [Circle] = []
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    
    private let usersKey = "connectosphere_users"
    private let circlesKey = "connectosphere_circles"
    private let postsKey = "connectosphere_posts"
    private let commentsKey = "connectosphere_comments"
    
    init() {
        loadData()
        if circles.isEmpty {
            createDefaultCircles()
        }
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
        users = []
        circles = []
        posts = []
        comments = []
        UserDefaults.standard.removeObject(forKey: usersKey)
        UserDefaults.standard.removeObject(forKey: circlesKey)
        UserDefaults.standard.removeObject(forKey: postsKey)
        UserDefaults.standard.removeObject(forKey: commentsKey)
        createDefaultCircles()
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
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveData()
        }
    }
    
    func getUser(byID id: String) -> User? {
        users.first(where: { $0.id == id })
    }
    
    // MARK: - Circle Management
    
    func createCircle(name: String, description: String, category: String, tags: [String], creatorID: String) -> Circle {
        let circle = Circle(
            id: UUID().uuidString,
            name: name,
            description: description,
            category: category,
            creatorID: creatorID,
            memberIDs: [creatorID],
            postIDs: [],
            createdAt: Date(),
            tags: tags
        )
        circles.append(circle)
        saveData()
        return circle
    }
    
    func joinCircle(circleID: String, userID: String) {
        if let circleIndex = circles.firstIndex(where: { $0.id == circleID }) {
            if !circles[circleIndex].memberIDs.contains(userID) {
                circles[circleIndex].memberIDs.append(userID)
            }
            if let userIndex = users.firstIndex(where: { $0.id == userID }) {
                if !users[userIndex].joinedCircleIDs.contains(circleID) {
                    users[userIndex].joinedCircleIDs.append(circleID)
                }
            }
            saveData()
        }
    }
    
    func leaveCircle(circleID: String, userID: String) {
        if let circleIndex = circles.firstIndex(where: { $0.id == circleID }) {
            circles[circleIndex].memberIDs.removeAll(where: { $0 == userID })
        }
        if let userIndex = users.firstIndex(where: { $0.id == userID }) {
            users[userIndex].joinedCircleIDs.removeAll(where: { $0 == circleID })
        }
        saveData()
    }
    
    func getUserCircles(userID: String) -> [Circle] {
        guard let user = getUser(byID: userID) else { return [] }
        return circles.filter { user.joinedCircleIDs.contains($0.id) }
    }
    
    // MARK: - Post Management
    
    func createPost(title: String, content: String, circleID: String, authorID: String) -> Post {
        let post = Post(
            id: UUID().uuidString,
            authorID: authorID,
            circleID: circleID,
            content: content,
            title: title,
            reactions: [],
            commentIDs: [],
            createdAt: Date()
        )
        posts.append(post)
        
        if let circleIndex = circles.firstIndex(where: { $0.id == circleID }) {
            circles[circleIndex].postIDs.append(post.id)
        }
        
        saveData()
        return post
    }
    
    func addReaction(postID: String, userID: String, type: ReactionType) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            // Remove existing reaction from this user
            posts[postIndex].reactions.removeAll(where: { $0.userID == userID })
            // Add new reaction
            let reaction = Reaction(userID: userID, type: type, timestamp: Date())
            posts[postIndex].reactions.append(reaction)
            saveData()
        }
    }
    
    func removeReaction(postID: String, userID: String) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            posts[postIndex].reactions.removeAll(where: { $0.userID == userID })
            saveData()
        }
    }
    
    func getCirclePosts(circleID: String) -> [Post] {
        posts.filter { $0.circleID == circleID }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func getFeedPosts(userID: String) -> [Post] {
        guard let user = getUser(byID: userID) else { return [] }
        return posts
            .filter { user.joinedCircleIDs.contains($0.circleID) }
            .sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    // MARK: - Comment Management
    
    func createComment(postID: String, authorID: String, content: String) -> Comment {
        let comment = Comment(
            id: UUID().uuidString,
            authorID: authorID,
            postID: postID,
            content: content,
            createdAt: Date()
        )
        comments.append(comment)
        
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            posts[postIndex].commentIDs.append(comment.id)
        }
        
        saveData()
        return comment
    }
    
    func getPostComments(postID: String) -> [Comment] {
        comments.filter { $0.postID == postID }.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    // MARK: - Default Data
    
    private func createDefaultCircles() {
        let sampleCircles = [
            Circle(
                id: UUID().uuidString,
                name: "Tech Enthusiasts",
                description: "Discuss the latest in technology, programming, and innovation",
                category: "Technology",
                creatorID: "system",
                memberIDs: [],
                postIDs: [],
                createdAt: Date(),
                tags: ["tech", "programming", "innovation"]
            ),
            Circle(
                id: UUID().uuidString,
                name: "Book Lovers",
                description: "Share your favorite reads and literary discoveries",
                category: "Literature",
                creatorID: "system",
                memberIDs: [],
                postIDs: [],
                createdAt: Date(),
                tags: ["books", "reading", "literature"]
            ),
            Circle(
                id: UUID().uuidString,
                name: "Fitness & Wellness",
                description: "Connect with others on their health and fitness journey",
                category: "Health",
                creatorID: "system",
                memberIDs: [],
                postIDs: [],
                createdAt: Date(),
                tags: ["fitness", "health", "wellness"]
            ),
            Circle(
                id: UUID().uuidString,
                name: "Creative Arts",
                description: "Share and appreciate art, music, and creative expression",
                category: "Arts",
                creatorID: "system",
                memberIDs: [],
                postIDs: [],
                createdAt: Date(),
                tags: ["art", "music", "creativity"]
            ),
            Circle(
                id: UUID().uuidString,
                name: "Travel & Adventure",
                description: "Explore the world together and share travel experiences",
                category: "Travel",
                creatorID: "system",
                memberIDs: [],
                postIDs: [],
                createdAt: Date(),
                tags: ["travel", "adventure", "explore"]
            )
        ]
        
        circles = sampleCircles
        saveData()
    }
}


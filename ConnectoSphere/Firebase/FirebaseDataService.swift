//
//  FirebaseDataService.swift
//  ConnectoSphere
//
import Foundation
import FirebaseFirestore
import Combine

class FirebaseDataService: ObservableObject {
    static let shared = FirebaseDataService()
    
    @Published var circles: [Circle] = []
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var users: [User] = []
    
    private let db = FirebaseManager.shared.db
    private var listeners: [ListenerRegistration] = []
    
    init() {
        setupListeners()
    }
    
    deinit {
        removeListeners()
    }
    
    // MARK: - Realtime Listeners
    
    private func setupListeners() {
        // Слушаем изменения в circles
        let circlesListener = db.collection("circles").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                print("❌ Error fetching circles: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            self.circles = documents.compactMap { try? $0.data(as: Circle.self) }
            print("✅ Loaded \(self.circles.count) circles")
        }
        listeners.append(circlesListener)
        
        // Слушаем изменения в posts
        let postsListener = db.collection("posts").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                print("❌ Error fetching posts: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            self.posts = documents.compactMap { try? $0.data(as: Post.self) }
            print("✅ Loaded \(self.posts.count) posts")
        }
        listeners.append(postsListener)
        
        // Слушаем изменения в comments
        let commentsListener = db.collection("comments").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                print("❌ Error fetching comments: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            self.comments = documents.compactMap { try? $0.data(as: Comment.self) }
            print("✅ Loaded \(self.comments.count) comments")
        }
        listeners.append(commentsListener)
    }
    
    private func removeListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    // MARK: - Circle Management
    
    func createCircle(name: String, description: String, category: String, tags: [String], creatorID: String, completion: @escaping (Circle?) -> Void) {
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
        
        do {
            try db.collection("circles").document(circle.id).setData(from: circle) { error in
                if let error = error {
                    print("❌ Error creating circle: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(circle)
                }
            }
        } catch {
            print("❌ Error encoding circle: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func joinCircle(circleID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let circleRef = db.collection("circles").document(circleID)
        let userRef = db.collection("users").document(userID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let circleDocument: DocumentSnapshot
            let userDocument: DocumentSnapshot
            
            do {
                try circleDocument = transaction.getDocument(circleRef)
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var circle = try? circleDocument.data(as: Circle.self),
                  var user = try? userDocument.data(as: User.self) else {
                return nil
            }
            
            if !circle.memberIDs.contains(userID) {
                circle.memberIDs.append(userID)
            }
            
            if !user.joinedCircleIDs.contains(circleID) {
                user.joinedCircleIDs.append(circleID)
            }
            
            do {
                try transaction.setData(from: circle, forDocument: circleRef, merge: true)
                try transaction.setData(from: user, forDocument: userRef, merge: true)
            } catch {
                return nil
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("❌ Transaction error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func leaveCircle(circleID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let circleRef = db.collection("circles").document(circleID)
        let userRef = db.collection("users").document(userID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let circleDocument: DocumentSnapshot
            let userDocument: DocumentSnapshot
            
            do {
                try circleDocument = transaction.getDocument(circleRef)
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var circle = try? circleDocument.data(as: Circle.self),
                  var user = try? userDocument.data(as: User.self) else {
                return nil
            }
            
            circle.memberIDs.removeAll(where: { $0 == userID })
            user.joinedCircleIDs.removeAll(where: { $0 == circleID })
            
            do {
                try transaction.setData(from: circle, forDocument: circleRef, merge: true)
                try transaction.setData(from: user, forDocument: userRef, merge: true)
            } catch {
                return nil
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("❌ Transaction error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Post Management
    
    func createPost(title: String, content: String, circleID: String, authorID: String, completion: @escaping (Post?) -> Void) {
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
        
        do {
            try db.collection("posts").document(post.id).setData(from: post) { error in
                if let error = error {
                    print("❌ Error creating post: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    // Обновляем circle
                    self.db.collection("circles").document(circleID).updateData([
                        "postIDs": FieldValue.arrayUnion([post.id])
                    ])
                    completion(post)
                }
            }
        } catch {
            print("❌ Error encoding post: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func addReaction(postID: String, userID: String, type: ReactionType, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(postID)
        
        postRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, var post = try? snapshot.data(as: Post.self) else {
                completion(false)
                return
            }
            
            // Удаляем существующую реакцию пользователя
            post.reactions.removeAll(where: { $0.userID == userID })
            
            // Добавляем новую реакцию
            let reaction = Reaction(userID: userID, type: type, timestamp: Date())
            post.reactions.append(reaction)
            
            do {
                try postRef.setData(from: post, merge: true) { error in
                    completion(error == nil)
                }
            } catch {
                completion(false)
            }
        }
    }
    
    func removeReaction(postID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(postID)
        
        postRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, var post = try? snapshot.data(as: Post.self) else {
                completion(false)
                return
            }
            
            post.reactions.removeAll(where: { $0.userID == userID })
            
            do {
                try postRef.setData(from: post, merge: true) { error in
                    completion(error == nil)
                }
            } catch {
                completion(false)
            }
        }
    }
    
    // MARK: - Comment Management
    
    func createComment(postID: String, authorID: String, content: String, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(
            id: UUID().uuidString,
            authorID: authorID,
            postID: postID,
            content: content,
            createdAt: Date()
        )
        
        do {
            try db.collection("comments").document(comment.id).setData(from: comment) { error in
                if let error = error {
                    print("❌ Error creating comment: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    // Обновляем post
                    self.db.collection("posts").document(postID).updateData([
                        "commentIDs": FieldValue.arrayUnion([comment.id])
                    ])
                    completion(comment)
                }
            }
        } catch {
            print("❌ Error encoding comment: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // MARK: - Helper Methods
    
    func getUser(byID id: String) -> User? {
        users.first(where: { $0.id == id })
    }
    
    func getUserCircles(userID: String) -> [Circle] {
        circles.filter { $0.memberIDs.contains(userID) }
    }
    
    func getCirclePosts(circleID: String) -> [Post] {
        posts.filter { $0.circleID == circleID }.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func getFeedPosts(userID: String) -> [Post] {
        let userCircleIDs = getUserCircles(userID: userID).map { $0.id }
        return posts
            .filter { userCircleIDs.contains($0.circleID) }
            .sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func getPostComments(postID: String) -> [Comment] {
        comments.filter { $0.postID == postID }.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    // MARK: - Initialize Default Data
    
    func initializeDefaultCircles() {
        // Проверяем, есть ли уже circles
        db.collection("circles").getDocuments { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.documents.isEmpty else {
                return
            }
            
            let defaultCircles = [
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
            
            let batch = self.db.batch()
            for circle in defaultCircles {
                let ref = self.db.collection("circles").document(circle.id)
                do {
                    try batch.setData(from: circle, forDocument: ref)
                } catch {
                    print("❌ Error adding circle to batch: \(error.localizedDescription)")
                }
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ Error creating default circles: \(error.localizedDescription)")
                } else {
                    print("✅ Default circles created")
                }
            }
        }
    }
}


//
//  FirebaseAuthService.swift
//  ConnectoSphere
//
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthService: ObservableObject {
    static let shared = FirebaseAuthService()
    
    @Published var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentUserID: String = UserDefaults.standard.string(forKey: "currentUserID") ?? "" {
        didSet {
            UserDefaults.standard.set(currentUserID, forKey: "currentUserID")
        }
    }
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let db = FirebaseManager.shared.db
    private let auth = FirebaseManager.shared.auth
    
    init() {
        // Проверяем есть ли активная сессия Firebase
        if let firebaseUser = auth.currentUser {
            loadUserData(firebaseUserID: firebaseUser.uid)
        }
    }
    
    // Анонимная авторизация для гостей
    func signInAnonymously(username: String, completion: @escaping (Bool) -> Void) {
        auth.signInAnonymously { [weak self] authResult, error in
            guard let self = self, let authResult = authResult, error == nil else {
                print("❌ Anonymous sign in error: \(error?.localizedDescription ?? "unknown")")
                completion(false)
                return
            }
            
            // Создаем пользователя в Firestore
            let user = User(
                id: authResult.user.uid,
                username: username,
                email: "",
                bio: "",
                profileTheme: .minimal,
                interestTags: [],
                joinedCircleIDs: [],
                isGuest: true,
                createdAt: Date()
            )
            
            self.createUserInFirestore(user: user) { success in
                if success {
                    self.currentUser = user
                    self.currentUserID = user.id
                    self.isAuthenticated = true
                    self.hasCompletedOnboarding = true
                }
                completion(success)
            }
        }
    }
    
    // Регистрация с email
    func signUpWithEmail(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self, let authResult = authResult, error == nil else {
                print("❌ Sign up error: \(error?.localizedDescription ?? "unknown")")
                completion(false)
                return
            }
            
            let user = User(
                id: authResult.user.uid,
                username: username,
                email: email,
                bio: "",
                profileTheme: .minimal,
                interestTags: [],
                joinedCircleIDs: [],
                isGuest: false,
                createdAt: Date()
            )
            
            self.createUserInFirestore(user: user) { success in
                if success {
                    self.currentUser = user
                    self.currentUserID = user.id
                    self.isAuthenticated = true
                    self.hasCompletedOnboarding = true
                }
                completion(success)
            }
        }
    }
    
    // Создание пользователя в Firestore
    private func createUserInFirestore(user: User, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("users").document(user.id).setData(from: user) { error in
                if let error = error {
                    print("❌ Error creating user in Firestore: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ User created in Firestore")
                    completion(true)
                }
            }
        } catch {
            print("❌ Error encoding user: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Загрузка данных пользователя
    private func loadUserData(firebaseUserID: String) {
        db.collection("users").document(firebaseUserID).getDocument { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists else {
                print("❌ User not found in Firestore")
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                self.currentUser = user
                self.currentUserID = user.id
                self.isAuthenticated = true
            } catch {
                print("❌ Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    // Обновление пользователя
    func updateUser(_ user: User, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("users").document(user.id).setData(from: user, merge: true) { error in
                if let error = error {
                    print("❌ Error updating user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.currentUser = user
                    completion(true)
                }
            }
        } catch {
            print("❌ Error encoding user: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Выход
    func logout() {
        do {
            try auth.signOut()
            currentUser = nil
            currentUserID = ""
            isAuthenticated = false
            hasCompletedOnboarding = false
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
    
    // Удаление аккаунта
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let firebaseUser = auth.currentUser else {
            completion(false)
            return
        }
        
        // Удаляем данные пользователя из Firestore
        let batch = db.batch()
        
        // Удаляем пользователя
        batch.deleteDocument(db.collection("users").document(firebaseUser.uid))
        
        // Удаляем посты пользователя
        db.collection("posts").whereField("authorID", isEqualTo: firebaseUser.uid).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                completion(false)
                return
            }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            // Удаляем комментарии пользователя
            self.db.collection("comments").whereField("authorID", isEqualTo: firebaseUser.uid).getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for document in documents {
                        batch.deleteDocument(document.reference)
                    }
                }
                
                // Выполняем batch удаление
                batch.commit { error in
                    if let error = error {
                        print("❌ Error deleting user data: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        // Удаляем аккаунт Firebase Auth
                        firebaseUser.delete { error in
                            if let error = error {
                                print("❌ Error deleting Firebase account: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                self.currentUser = nil
                                self.currentUserID = ""
                                self.isAuthenticated = false
                                self.hasCompletedOnboarding = false
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
}


//
//  FirebaseManager.swift
//  ConnectoSphere
//
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    private init() {
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
}


//
//  User.swift
//  ConnectoSphere
//
//
import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var email: String
    var bio: String
    var profileTheme: ProfileTheme
    var interestTags: [String]
    var joinedCircleIDs: [String]
    var isGuest: Bool
    var createdAt: Date
    
    enum ProfileTheme: String, Codable, CaseIterable {
        case sunset = "Sunset"
        case ocean = "Ocean"
        case forest = "Forest"
        case cosmic = "Cosmic"
        case minimal = "Minimal"
    }
    
    static func guest() -> User {
        User(
            id: UUID().uuidString,
            username: "Guest User",
            email: "",
            bio: "",
            profileTheme: .minimal,
            interestTags: [],
            joinedCircleIDs: [],
            isGuest: true,
            createdAt: Date()
        )
    }
}


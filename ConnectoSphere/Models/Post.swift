//
//  Post.swift
//  ConnectoSphere
//
//

import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: String
    var authorID: String
    var circleID: String
    var content: String
    var title: String
    var reactions: [Reaction]
    var commentIDs: [String]
    var createdAt: Date
    
    func reactionCount(for type: ReactionType) -> Int {
        reactions.filter { $0.type == type }.count
    }
}

struct Reaction: Codable, Hashable {
    let userID: String
    let type: ReactionType
    let timestamp: Date
}

enum ReactionType: String, Codable, CaseIterable {
    case like = "👍"
    case love = "❤️"
    case insightful = "💡"
    case funny = "😄"
}


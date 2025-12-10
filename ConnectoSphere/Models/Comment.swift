//
//  Comment.swift
//  ConnectoSphere
//
//

import Foundation

struct Comment: Identifiable, Codable, Hashable {
    let id: String
    var authorID: String
    var postID: String
    var content: String
    var createdAt: Date
}


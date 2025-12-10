//
//  Circle.swift
//  ConnectoSphere
//
//
import Foundation

struct Circle: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var description: String
    var category: String
    var creatorID: String
    var memberIDs: [String]
    var postIDs: [String]
    var createdAt: Date
    var tags: [String]
    
    var memberCount: Int {
        memberIDs.count
    }
}


//
//  ConnectionService.swift
//  ConnectoSphere
//
//

import Foundation

class ConnectionService {
    static let shared = ConnectionService()
    
    private let dataService = DataService.shared
    
    // Interest Matching Algorithm
    func suggestConnections(for userID: String, limit: Int = 10) -> [Connection] {
        guard let currentUser = dataService.getUser(byID: userID) else { return [] }
        
        var connections: [Connection] = []
        
        for user in dataService.users {
            // Skip self and guests
            if user.id == userID || user.isGuest { continue }
            
            // Calculate match score
            let score = calculateMatchScore(user1: currentUser, user2: user)
            
            if score > 0 {
                let commonCircles = Array(Set(currentUser.joinedCircleIDs).intersection(Set(user.joinedCircleIDs)))
                let commonTags = Array(Set(currentUser.interestTags).intersection(Set(user.interestTags)))
                
                let connection = Connection(
                    id: UUID().uuidString,
                    userID: user.id,
                    matchScore: score,
                    commonCircles: commonCircles,
                    commonTags: commonTags
                )
                connections.append(connection)
            }
        }
        
        // Sort by match score and limit results
        return Array(connections.sorted(by: { $0.matchScore > $1.matchScore }).prefix(limit))
    }
    
    private func calculateMatchScore(user1: User, user2: User) -> Double {
        var score: Double = 0
        
        // Common circles (highest weight)
        let commonCircles = Set(user1.joinedCircleIDs).intersection(Set(user2.joinedCircleIDs))
        score += Double(commonCircles.count) * 10.0
        
        // Common interest tags
        let commonTags = Set(user1.interestTags).intersection(Set(user2.interestTags))
        score += Double(commonTags.count) * 5.0
        
        // Interaction score based on shared circles activity
        for circleID in commonCircles {
            let user1Posts = dataService.posts.filter { $0.authorID == user1.id && $0.circleID == circleID }
            let user2Posts = dataService.posts.filter { $0.authorID == user2.id && $0.circleID == circleID }
            
            // Active users in same circles get bonus points
            if !user1Posts.isEmpty && !user2Posts.isEmpty {
                score += 3.0
            }
        }
        
        return score
    }
}


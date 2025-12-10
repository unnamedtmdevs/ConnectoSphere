//
//  PostCard.swift
//  ConnectoSphere
//
//

import SwiftUI

struct PostCard: View {
    let post: Post
    let onReaction: (ReactionType) -> Void
    let onComment: () -> Void
    let userReaction: ReactionType?
    
    @ObservedObject private var dataService = DataService.shared
    
    var author: User? {
        dataService.getUser(byID: post.authorID)
    }
    
    var circle: Circle? {
        dataService.circles.first(where: { $0.id == post.circleID })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.accentGreen)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(author?.username ?? "Unknown User")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 5) {
                        if let circle = circle {
                            Text(circle.name)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("•")
                                .foregroundColor(.secondary)
                        }
                        Text(post.createdAt, style: .relative)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(post.content)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(5)
            }
            
            // Reactions and Comments
            VStack(spacing: 10) {
                // Reaction counts
                if !post.reactions.isEmpty {
                    HStack(spacing: 15) {
                        ForEach(ReactionType.allCases, id: \.self) { type in
                            let count = post.reactionCount(for: type)
                            if count > 0 {
                                HStack(spacing: 4) {
                                    Text(type.rawValue)
                                    Text("\(count)")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                    }
                    .font(.system(size: 14))
                }
                
                Divider()
                
                // Action buttons
                HStack(spacing: 0) {
                    // Reactions button
                    Menu {
                        ForEach(ReactionType.allCases, id: \.self) { type in
                            Button(action: {
                                onReaction(type)
                            }) {
                                HStack {
                                    Text(type.rawValue)
                                    if userReaction == type {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: userReaction != nil ? "hand.thumbsup.fill" : "hand.thumbsup")
                            Text("React")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(userReaction != nil ? AppColors.accentGreen : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Comment button
                    Button(action: onComment) {
                        HStack {
                            Image(systemName: "message")
                            Text("Comment")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                RoundedRectangle(cornerRadius: 15)
                    .fill(AppColors.glassOverlay)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}


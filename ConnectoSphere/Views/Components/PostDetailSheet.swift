//
//  PostDetailSheet.swift
//  ConnectoSphere
//
//

import SwiftUI

struct PostDetailSheet: View {
    let post: Post
    @ObservedObject private var dataService = DataService.shared
    @ObservedObject private var authService = AuthService.shared
    @State private var commentText = ""
    @State private var comments: [Comment] = []
    @Environment(\.dismiss) private var dismiss
    
    var author: User? {
        dataService.getUser(byID: post.authorID)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.secondaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Post content
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(AppColors.accentGreen)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(author?.username ?? "Unknown User")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text(post.createdAt, style: .relative)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text(post.title)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(post.content)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                // Reactions summary
                                if !post.reactions.isEmpty {
                                    HStack(spacing: 15) {
                                        ForEach(ReactionType.allCases, id: \.self) { type in
                                            let count = post.reactionCount(for: type)
                                            if count > 0 {
                                                HStack(spacing: 4) {
                                                    Text(type.rawValue)
                                                        .font(.system(size: 20))
                                                    Text("\(count)")
                                                        .font(.system(size: 14, design: .rounded))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                            
                            // Comments section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Comments (\(comments.count))")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                if comments.isEmpty {
                                    Text("No comments yet. Be the first to comment!")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 30)
                                } else {
                                    ForEach(comments) { comment in
                                        CommentRow(comment: comment)
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                    
                    // Comment input
                    Divider()
                    
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $commentText)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                        
                        Button(action: addComment) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(commentText.isEmpty ? .secondary : AppColors.accentGreen)
                        }
                        .disabled(commentText.isEmpty)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadComments()
            }
        }
    }
    
    private func loadComments() {
        comments = dataService.getPostComments(postID: post.id)
    }
    
    private func addComment() {
        guard !commentText.isEmpty, let userID = authService.currentUser?.id else { return }
        
        _ = dataService.createComment(postID: post.id, authorID: userID, content: commentText)
        commentText = ""
        loadComments()
    }
}

struct CommentRow: View {
    let comment: Comment
    @ObservedObject private var dataService = DataService.shared
    
    var author: User? {
        dataService.getUser(byID: comment.authorID)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 35))
                .foregroundStyle(AppColors.accentGreen)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(author?.username ?? "Unknown User")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(comment.createdAt, style: .relative)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}


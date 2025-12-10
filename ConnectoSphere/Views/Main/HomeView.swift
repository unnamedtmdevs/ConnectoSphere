//
//  HomeView.swift
//  ConnectoSphere
//
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var dataService = DataService.shared
    @State private var selectedPost: Post?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.secondaryBackground.opacity(0.3), AppColors.tertiaryBackground.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Suggested Connections Section
                        if !viewModel.suggestedConnections.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("People You Might Connect With")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.suggestedConnections) { connection in
                                            if let user = dataService.getUser(byID: connection.userID) {
                                                ConnectionCard(user: user, connection: connection)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        // Feed Posts
                        VStack(spacing: 15) {
                            if viewModel.feedPosts.isEmpty {
                                EmptyFeedView()
                                    .padding(.top, 50)
                            } else {
                                ForEach(viewModel.feedPosts) { post in
                                    PostCard(
                                        post: post,
                                        onReaction: { type in
                                            viewModel.toggleReaction(postID: post.id, type: type)
                                        },
                                        onComment: {
                                            selectedPost = post
                                        },
                                        userReaction: viewModel.getUserReaction(for: post.id)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.loadFeed()
                    viewModel.loadSuggestedConnections()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedPost) { post in
            PostDetailSheet(post: post)
        }
    }
}

struct ConnectionCard: View {
    let user: User
    let connection: Connection
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(AppColors.accentGreen)
            
            Text(user.username)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text("\(connection.commonCircles.count) common circles")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
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

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Your Feed is Empty")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Join some circles to see posts in your feed")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}


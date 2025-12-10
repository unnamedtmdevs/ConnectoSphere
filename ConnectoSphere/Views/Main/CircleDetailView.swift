//
//  CircleDetailView.swift
//  ConnectoSphere
//
//

import SwiftUI

struct CircleDetailView: View {
    let circle: Circle
    @StateObject private var viewModel: CircleDetailViewModel
    @State private var showingCreatePost = false
    @State private var selectedPost: Post?
    @Environment(\.dismiss) private var dismiss
    
    init(circle: Circle) {
        self.circle = circle
        _viewModel = StateObject(wrappedValue: CircleDetailViewModel(circle: circle))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Circle Header
                        VStack(spacing: 15) {
                            Image(systemName: "circle.hexagongrid.circle.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(AppColors.accentGreen)
                            
                            Text(circle.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(circle.description)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 20) {
                                Label("\(circle.memberCount)", systemImage: "person.2.fill")
                                Label("\(viewModel.posts.count)", systemImage: "doc.text.fill")
                            }
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(circle.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 14, design: .rounded))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(AppColors.tertiaryBackground)
                                            )
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Posts
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Posts")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: { showingCreatePost = true }) {
                                    Label("New Post", systemImage: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.accentGreen)
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.posts.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.secondary)
                                    Text("No posts yet")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text("Be the first to share something!")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 50)
                            } else {
                                ForEach(viewModel.posts) { post in
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
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.loadPosts()
                }
            }
            .navigationTitle(circle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostSheet(
                isPresented: $showingCreatePost,
                onCreate: { title, content in
                    viewModel.createPost(title: title, content: content)
                }
            )
        }
        .sheet(item: $selectedPost) { post in
            PostDetailSheet(post: post)
        }
    }
}

struct CreatePostSheet: View {
    @Binding var isPresented: Bool
    let onCreate: (String, String) -> Void
    
    @State private var title = ""
    @State private var content = ""
    
    var isValid: Bool {
        !title.isEmpty && !content.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.secondaryBackground.opacity(0.3), AppColors.tertiaryBackground.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Post Details") {
                        TextField("Title", text: $title)
                        TextField("What's on your mind?", text: $content, axis: .vertical)
                            .lineLimit(5...15)
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Post") {
                    onCreate(title, content)
                    isPresented = false
                }
                .disabled(!isValid)
                .fontWeight(.bold)
            )
        }
    }
}


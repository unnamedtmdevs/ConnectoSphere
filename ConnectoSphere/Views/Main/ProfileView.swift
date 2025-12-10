//
//  ProfileView.swift
//  ConnectoSphere
//
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primaryBackground.opacity(0.3), AppColors.secondaryBackground.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Header
                        VStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 100))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.accentGreen, AppColors.accentYellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(viewModel.user?.username ?? "User")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            if let bio = viewModel.user?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: { showingEditProfile = true }) {
                                Text("Edit Profile")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(AppColors.accentGreen)
                                    )
                            }
                        }
                        .padding(.top)
                        
                        // Interest Tags
                        if let tags = viewModel.user?.interestTags, !tags.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Interests")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(tags, id: \.self) { tag in
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
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Stats
                        HStack(spacing: 40) {
                            StatItem(title: "Posts", value: "\(viewModel.userPosts.count)")
                            StatItem(title: "Circles", value: "\(viewModel.userCircles.count)")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        )
                        .padding(.horizontal)
                        
                        // User's Posts
                        if !viewModel.userPosts.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("My Posts")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.userPosts) { post in
                                    ProfilePostCard(post: post)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.loadUserData()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet(
                isPresented: $showingEditProfile,
                viewModel: viewModel
            )
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct ProfilePostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(post.content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Label("\(post.reactions.count)", systemImage: "hand.thumbsup.fill")
                Label("\(post.commentIDs.count)", systemImage: "message.fill")
                Spacer()
                Text(post.createdAt, style: .relative)
            }
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

struct EditProfileSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var selectedTheme: User.ProfileTheme = .minimal
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
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
                    Section("Profile Information") {
                        TextField("Username", text: $username)
                        TextField("Bio", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    Section("Theme") {
                        Picker("Profile Theme", selection: $selectedTheme) {
                            ForEach(User.ProfileTheme.allCases, id: \.self) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Interest Tags") {
                        HStack {
                            TextField("Add a tag", text: $tagInput)
                            Button("Add") {
                                if !tagInput.isEmpty {
                                    tags.append(tagInput)
                                    tagInput = ""
                                }
                            }
                            .disabled(tagInput.isEmpty)
                        }
                        
                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack {
                                            Text("#\(tag)")
                                            Button(action: {
                                                tags.removeAll(where: { $0 == tag })
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Capsule().fill(AppColors.tertiaryBackground.opacity(0.3)))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateProfile(username: username, bio: bio, theme: selectedTheme, tags: tags)
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                if let user = viewModel.user {
                    username = user.username
                    bio = user.bio
                    selectedTheme = user.profileTheme
                    tags = user.interestTags
                }
            }
        }
    }
}


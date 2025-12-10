//
//  SettingsView.swift
//  ConnectoSphere
//
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var authService = AuthService.shared
    @State private var showingDeleteConfirmation = false
    @State private var showingLogoutConfirmation = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Account") {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(authService.currentUser?.username ?? "Guest")
                                .foregroundColor(.secondary)
                        }
                        
                        if let user = authService.currentUser, !user.isGuest {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(user.email)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Account Type")
                            Spacer()
                            Text(authService.currentUser?.isGuest == true ? "Guest" : "Registered")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Privacy") {
                        NavigationLink(destination: PrivacySettingsView()) {
                            Label("Privacy Settings", systemImage: "hand.raised.fill")
                        }
                        
                        NavigationLink(destination: DataManagementView()) {
                            Label("Data Management", systemImage: "folder.fill")
                        }
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            Label("About ConnectoSphere", systemImage: "info.circle.fill")
                        }
                    }
                    
                    Section {
                        Button(action: {
                            showingLogoutConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Logout")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .foregroundColor(AppColors.accentYellow)
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Delete Account")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .foregroundColor(AppColors.accentRed)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Logout", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    authService.deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
        }
    }
}

struct PrivacySettingsView: View {
    @State private var showProfileToEveryone = true
    @State private var allowConnectionSuggestions = true
    @State private var showActivityStatus = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Form {
                Section("Profile Visibility") {
                    Toggle("Show Profile to Everyone", isOn: $showProfileToEveryone)
                    Text("When disabled, only members of your circles can see your profile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Connections") {
                    Toggle("Allow Connection Suggestions", isOn: $allowConnectionSuggestions)
                    Text("Let others discover you through the 'People You Might Connect With' feature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Activity") {
                    Toggle("Show Activity Status", isOn: $showActivityStatus)
                    Text("Let others see when you're active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Privacy Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataManagementView: View {
    @ObservedObject private var dataService = DataService.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Form {
                Section("Your Data") {
                    HStack {
                        Text("Posts Created")
                        Spacer()
                        Text("\(dataService.posts.filter { $0.authorID == AuthService.shared.currentUser?.id }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Comments Made")
                        Spacer()
                        Text("\(dataService.comments.filter { $0.authorID == AuthService.shared.currentUser?.id }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Circles Joined")
                        Spacer()
                        Text("\(AuthService.shared.currentUser?.joinedCircleIDs.count ?? 0)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data Information") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Local Storage")
                            .font(.headline)
                        Text("All your data is stored locally on your device. We don't collect or transmit any personal information to external servers.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(AppColors.accentGreen)
                        .padding(.top, 40)
                    
                    Text("ConnectoSphere")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        
                        Text("ConnectoSphere is a modern social networking app designed for creating enriching conversations and sharing content in niche communities. Connect with people who share your interests and engage in meaningful discussions.")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Features")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        
                        FeatureRow(icon: "circle.hexagongrid.circle.fill", title: "Community Circles", description: "Join topic-based communities")
                        FeatureRow(icon: "person.2.circle.fill", title: "Interest Matching", description: "Discover like-minded people")
                        FeatureRow(icon: "paintbrush.fill", title: "Customizable Profiles", description: "Express your personality")
                        FeatureRow(icon: "lock.shield.fill", title: "Privacy First", description: "Your data stays on your device")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(AppColors.accentGreen)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}


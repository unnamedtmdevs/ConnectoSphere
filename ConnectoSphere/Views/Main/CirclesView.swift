//
//  CirclesView.swift
//  ConnectoSphere
//
//

import SwiftUI

struct CirclesView: View {
    @StateObject private var viewModel = CirclesViewModel()
    @State private var selectedCircle: Circle?
    @State private var showingCreateCircle = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primaryBackground.opacity(0.2), AppColors.tertiaryBackground.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search circles...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .padding()
                    
                    // Tabs
                    Picker("", selection: $selectedTab) {
                        Text("My Circles").tag(0)
                        Text("Discover").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            if selectedTab == 0 {
                                // My Circles
                                if viewModel.myCircles.isEmpty {
                                    EmptyCirclesView()
                                        .padding(.top, 50)
                                } else {
                                    ForEach(viewModel.myCircles) { circle in
                                        CircleCard(
                                            circle: circle,
                                            isMember: true,
                                            onTap: { selectedCircle = circle },
                                            onAction: { viewModel.leaveCircle(circle) }
                                        )
                                    }
                                }
                            } else {
                                // Discover
                                ForEach(viewModel.filteredCircles) { circle in
                                    CircleCard(
                                        circle: circle,
                                        isMember: viewModel.isUserMember(of: circle),
                                        onTap: { selectedCircle = circle },
                                        onAction: {
                                            if viewModel.isUserMember(of: circle) {
                                                viewModel.leaveCircle(circle)
                                            } else {
                                                viewModel.joinCircle(circle)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Circles")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCircle = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.accentGreen)
                    }
                }
            }
        }
        .sheet(item: $selectedCircle) { circle in
            CircleDetailView(circle: circle)
        }
        .sheet(isPresented: $showingCreateCircle) {
            CreateCircleSheet(
                isPresented: $showingCreateCircle,
                onCreate: { name, description, category, tags in
                    viewModel.createCircle(name: name, description: description, category: category, tags: tags)
                }
            )
        }
        .onAppear {
            viewModel.loadCircles()
        }
    }
}

struct CircleCard: View {
    let circle: Circle
    let isMember: Bool
    let onTap: () -> Void
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(circle.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(circle.category)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: onAction) {
                        Text(isMember ? "Leave" : "Join")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isMember ? AppColors.accentRed : AppColors.accentGreen)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                Text(circle.description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(circle.memberCount)", systemImage: "person.2.fill")
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(circle.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 12, design: .rounded))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.tertiaryBackground.opacity(0.3))
                                    )
                            }
                        }
                    }
                }
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
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
                    .stroke(isMember ? AppColors.accentGreen : AppColors.glassBorder, lineWidth: isMember ? 2 : 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5)
        }
    }
}

struct EmptyCirclesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "circle.hexagongrid")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Circles Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Join circles to connect with people who share your interests")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct CreateCircleSheet: View {
    @Binding var isPresented: Bool
    let onCreate: (String, String, String, [String]) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var category = "General"
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    let categories = ["Technology", "Arts", "Sports", "Health", "Education", "Entertainment", "General"]
    
    var isValid: Bool {
        !name.isEmpty && !description.isEmpty && !category.isEmpty
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
                    Section("Circle Information") {
                        TextField("Name", text: $name)
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                    }
                    
                    Section("Tags") {
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
            .navigationTitle("Create Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate(name, description, category, tags)
                        isPresented = false
                    }
                    .disabled(!isValid)
                    .fontWeight(.bold)
                }
            }
        }
    }
}


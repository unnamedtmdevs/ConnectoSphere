//
//  AuthScreen.swift
//  ConnectoSphere
//
//

import SwiftUI

struct AuthScreen: View {
    @ObservedObject var authService = AuthService.shared
    @State private var username = ""
    @State private var email = ""
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.secondaryBackground, AppColors.primaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.accentGreen)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    
                    Text("Join ConnectoSphere")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 20) {
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text(AppStrings.signUpWithEmail)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppColors.accentGreen)
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppColors.glassOverlay)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.glassBorder, lineWidth: 1)
                            )
                            .shadow(color: AppColors.accentGreen.opacity(0.5), radius: 10)
                    }
                    
                    Button(action: {
                        authService.continueAsGuest()
                    }) {
                        Text(AppStrings.continueAsGuest)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppColors.primaryBackground.opacity(0.6))
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppColors.glassOverlay)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.glassBorder, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpSheet(
                username: $username,
                email: $email,
                isPresented: $showingSignUp,
                onSignUp: {
                    authService.signUpWithEmail(username: username, email: email)
                }
            )
        }
    }
}

struct SignUpSheet: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var isPresented: Bool
    let onSignUp: () -> Void
    
    var isValid: Bool {
        !username.isEmpty && !email.isEmpty && email.contains("@")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.secondaryBackground, AppColors.tertiaryBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.accentGreen)
                        .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Enter your username", text: $username)
                                .textFieldStyle(GlassTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(GlassTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        onSignUp()
                        isPresented = false
                    }) {
                        Text("Create Account")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(isValid ? AppColors.accentGreen : Color.gray)
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppColors.glassOverlay)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.glassBorder, lineWidth: 1)
                            )
                            .shadow(color: isValid ? AppColors.accentGreen.opacity(0.5) : .clear, radius: 10)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.glassOverlay)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.glassBorder, lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}


//
//  LoginView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case server, username, password
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // App logo/icon
                VStack(spacing: 8) {
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                    
                    Text("IPTV Player")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                // Login form
                VStack(spacing: 20) {
                    // Server URL field
                    VStack(alignment: .leading) {
                        Text("Server URL")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("", text: $authViewModel.serverURL)
                                .placeholder(when: authViewModel.serverURL.isEmpty) {
                                    Text("http://example.com")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .server)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .username
                                }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Username field
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("", text: $authViewModel.username)
                                .placeholder(when: authViewModel.username.isEmpty) {
                                    Text("username")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Password field
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.white.opacity(0.7))
                            
                            SecureField("", text: $authViewModel.password)
                                .placeholder(when: authViewModel.password.isEmpty) {
                                    Text("password")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.done)
                                .onSubmit {
                                    if authViewModel.isFormValid {
                                        login()
                                    }
                                }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 32)
                
                // Error message if any
                if let error = authViewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 32)
                }
                
                // Login button
                Button(action: login) {
                    if authViewModel.isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        Text("Sign In")
                            .fontWeight(.bold)
                    }
                }
                .frame(width: 200)
                .padding()
                .background(authViewModel.isFormValid ? Color.white : Color.white.opacity(0.3))
                .foregroundColor(authViewModel.isFormValid ? .blue : .white.opacity(0.5))
                .cornerRadius(10)
                .disabled(!authViewModel.isFormValid || authViewModel.isAuthenticating)
                .shadow(radius: authViewModel.isFormValid ? 5 : 0)
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private func login() {
        withAnimation {
            focusedField = nil
        }
        
        Task {
            await authViewModel.login()
        }
    }
}

// Extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

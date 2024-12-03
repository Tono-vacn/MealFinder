//
//  LoginView.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/18/24.
//
import SwiftUI
import Combine

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @Binding var isLoggedIn: Bool
    
    let userService = UserService()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Login")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Button(action: loginUser) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Navigate to RegisterView
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
    
    private func loginUser() {
        userService.loginUser(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "userToken")
                    isLoggedIn = true
                case .failure(_):
                    errorMessage = "Login failed. Please check your username and password."
                }
            }
        }
    }
}

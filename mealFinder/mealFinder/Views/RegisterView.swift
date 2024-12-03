//
//  RegisterView.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/18/24.
//
import SwiftUI
import Combine

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isSuccess: Bool = false

    let userService = UserService()
    
    var body: some View {
        VStack {
            Spacer()
            Text("Register")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            if isSuccess {
                Text("Registration successful! Please login.")
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
            
            Button(action: registerUser) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            Spacer()
        }
    }
    
    private func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        userService.registerUser(username: username, email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isSuccess = true
                    errorMessage = nil
                case .failure(let error):
                    isSuccess = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

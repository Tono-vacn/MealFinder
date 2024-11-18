//
//  LogoutView.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/18/24.
//

import SwiftUI

struct LogoutView: View {
    @Binding var isLoggedIn: Bool // Bind to ContentView's login status

    var body: some View {
        VStack(spacing: 20) {
            Text("Are you sure you want to log out?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: logout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    private func logout() {
        // Clear the user token from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userToken")
        isLoggedIn = false // Update login status
    }
}

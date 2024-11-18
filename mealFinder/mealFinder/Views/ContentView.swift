//
//  ContentView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @State private var isLoggedIn: Bool = false // Tracks login status
    
    var body: some View {
        ZStack {
            if isLoggedIn {
                // Main TabView shown after login
                TabView {
                    FindView()
                        .tabItem {
                            Label("Find", systemImage: "magnifyingglass")
                        }
                    LibView()
                        .tabItem {
                            Label("Library", systemImage: "books.vertical")
                        }
                    ForumView()
                        .tabItem {
                            Label("Forum", systemImage: "person.3")
                        }
                    LogoutView(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Label("Logout", systemImage: "arrow.backward.circle")
                        }
                }
            } else {
                // Show LoginView when not logged in
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }.onAppear {
            if let _ = UserDefaults.standard.string(forKey: "userToken") {
                isLoggedIn = true
            }
        }
    }
}


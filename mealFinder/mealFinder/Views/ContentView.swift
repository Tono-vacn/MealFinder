//
//  ContentView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    var body: some View {
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
        }
    }
}

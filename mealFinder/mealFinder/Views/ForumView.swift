//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct ForumView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var errorMessage: String? 

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading posts...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.headline)
                                Text("Likes: \(post.likes), Dislikes: \(post.dislikes)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(post.content)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                                Text("Created At: \(formatDate(post.createdAt))")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Forum")
            .onAppear {
                loadPosts()
            }
        }
    }

    func loadPosts() {
        PostService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func formatDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
}

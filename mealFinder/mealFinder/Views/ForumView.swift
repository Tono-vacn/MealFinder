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
    @State private var currentUserId: String?
    
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
                        NavigationLink(destination: PostDetailView(post: post, currentUserId: currentUserId ?? "")) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top){
                                    if let imageUrlString = post.recipe!.image,
                                       let imageUrl = URL(string: imageUrlString) {
                                        AsyncImage(url: imageUrl) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            EmptyView()
                                        }
                                        .frame(width: 80, height: 60)
                                        .cornerRadius(8)
                                        .clipped()
                                    }
                                    VStack(alignment: .leading){
                                        
                                        Text(post.title)
                                            .font(.headline)
                                        Text(post.content)
                                            .lineLimit(1)
                                            .foregroundColor(.secondary)
                                        Text("Likes: \(post.likes), Dislikes: \(post.dislikes)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                    }
                                }
                                

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
                fetchCurrentUserId()
                loadPosts()
            }
        }
    }
    
    func fetchCurrentUserId() {
        UserService.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userId):
                    self.currentUserId = userId
                case .failure(let error):
                    self.errorMessage = "Failed to fetch user ID: \(error.localizedDescription)"
                }
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

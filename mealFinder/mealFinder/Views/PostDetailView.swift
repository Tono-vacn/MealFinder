//
//  PostDetailView.swift
//  mealFinder
//
//  Created by Shujie on 11/6/24.
//

import SwiftUI

struct PostDetailView: View {
    //let post: Post
    @State private var post: Post
    @State private var isProcessingLike = false
    @State private var isProcessingDislike = false
    @State private var errorMessage: String? = nil
    let currentUserId: String
    @Environment(\.dismiss) private var dismiss
    
    init(post: Post, currentUserId: String) {
        _post = State(initialValue: post)
        self.currentUserId = currentUserId
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(post.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                
                
                HStack {
                    Text("Created At: \(formatDate(post.createdAt))")
                    Text("Updated At: \(formatDate(post.updatedAt))")
                }
                .font(.footnote)
                .foregroundColor(.gray)
                
                Divider()
                
                
                Text(post.content)
                    .font(.body)
                    .padding(.top, 10)
                
                Divider()
                
                HStack {
                    Button(action: {
                        likePost()
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text("Like (\(post.likes))")
                        }
                    }
                    .disabled(isProcessingLike)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button(action: {
                        dislikePost()
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsdown")
                            Text("Dislike (\(post.dislikes))")
                        }
                    }
                    .disabled(isProcessingDislike)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if post.userId == currentUserId { // only shows when the person is the person who write the post
                    Button(action: deletePost) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .background(HideTabBarView())
    }
    
    func likePost() {
        isProcessingLike = true
        errorMessage = nil
        PostService.shared.likePost(postId: post.id) { result in
            DispatchQueue.main.async {
                isProcessingLike = false
                switch result {
                case .success:
                    refreshPost()
                    //print("refreshed")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Dislike Post
    func dislikePost() {
        isProcessingDislike = true
        errorMessage = nil
        PostService.shared.dislikePost(postId: post.id) { result in
            DispatchQueue.main.async {
                isProcessingDislike = false
                switch result {
                case .success:
                    refreshPost()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func refreshPost() {
        
        PostService.shared.fetchPost(by: post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedPost):
                    post = updatedPost
                    print(post.likes)
                    print("refresh succ")
                case .failure(let error):
                    print("refresh fail")
                    errorMessage = "Failed to refresh post: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deletePost() {
        PostService.shared.deletePost(postId: post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("delete successfully")
                    dismiss()
                case .failure(let error):
                    errorMessage = "Failed to delete post: \(error.localizedDescription)"
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


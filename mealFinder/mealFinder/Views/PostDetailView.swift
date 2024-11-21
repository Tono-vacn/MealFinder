//
//  PostDetailView.swift
//  mealFinder
//
//  Created by Shujie on 11/6/24.
//

import SwiftUI

struct PostDetailView: View {
    @State private var post: Post
    @State private var comments: [CommentDTO] = []
    @State private var isProcessingLike = false
    @State private var isProcessingDislike = false
    @State private var errorMessage: String? = nil
    @State private var isShowingCommentInput = false
    @State private var commentTitle = ""
    @State private var commentContent = ""
    @State private var isShowingDeleteConfirm = false
    @State private var username: String = "Unknown"

    
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
                
                
                Text("Created At: \(formatDate(post.createdAt))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text("Posted by: \(username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                Text(post.content)
                    .font(.body)
                    .padding(.top, 10)
                
                Text("Related recipe: \(post.recipe!.title)")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if let imageUrlString = post.recipe!.image,
                   let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                    } placeholder: {
                        EmptyView()
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.vertical)
                }
                
                Text(post.recipe!.content)
                    .font(.body)
                    .padding(.top, 10)
                
                Divider()
                
                HStack {
                    Button(action: likePost) {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text("\(post.likes)")
                        }
                    }
                    .disabled(isProcessingLike)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button(action: dislikePost) {
                        HStack {
                            Image(systemName: "hand.thumbsdown")
                            Text("\(post.dislikes)")
                        }
                    }
                    .disabled(isProcessingDislike)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button(action: {
                        isShowingCommentInput = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Add Comment")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
                
                
                Divider()
                
                Text("Comments")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if comments.isEmpty {
                    Text("No comments yet.")
                        .foregroundColor(.gray)
                } else {
//                    ZStack{
                        ForEach($comments) { $comment in
                            CommentView(
                                comment: $comment,
                                currentUserId: currentUserId,
                                onCommentUpdated: { loadComments() },
                                onDelete: { deletedCommentId in
                                    deleteCommentFromList(deletedCommentId)
                                }
                            )
                        }
//                    }
//                    .padding(.bottom)
                }
                
                Spacer()
                
                
            }
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(){loadComments()
            fetchPostUser()}
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if post.userId == currentUserId {
                    Button(action:{isShowingDeleteConfirm = true}) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $isShowingDeleteConfirm) {
                        Alert(
                            title: Text("Confirm Delete"),
                            message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deletePost()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
        .background(HideTabBarView())
        .sheet(isPresented: $isShowingCommentInput) {
            VStack {
                Text("Add Comment")
                    .font(.headline)
                    .padding()
                
                TextField("Comment Title", text: $commentTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Comment Content", text: $commentContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        isShowingCommentInput = false
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Submit") {
                        submitComment()
                        isShowingCommentInput = false
                    }
                    .foregroundColor(.blue)
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
//        .alert(isPresented: $isShowingDeleteConfirm) {
//            Alert(
//                title: Text("Confirm Delete"),
//                message: Text("Are you sure you want to delete this post? This action cannot be undone."),
//                primaryButton: .destructive(Text("Delete")) {
//                    deletePost()
//                },
//                secondaryButton: .cancel()
//            )
//        }
    }
    
    func deleteCommentFromList(_ commentId: UUID) {
        comments.removeAll { $0.id == commentId }
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
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
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
                case .failure(let error):
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
    
    func submitComment() {
        let newComment = CreateCommentRequest(title: commentTitle, content: commentContent)
        
        CommentService.shared.addComment(postId: post.id, comment: newComment) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    loadComments()
                case .failure(let error):
                    errorMessage = "Failed to submit comment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadComments() {
        CommentService.shared.fetchComments(for: post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedComments):
                    comments = fetchedComments
                case .failure(let error):
                    errorMessage = "Failed to load comments: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchPostUser() {
        guard let userId = post.userId else { return }
        UserService.shared.fetchUser(by: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.username = user.username
                case .failure(let error):
                    print("Failed to fetch user: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

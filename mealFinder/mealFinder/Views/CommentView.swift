//
//  CommentView.swift
//  mealFinder
//
//  Created by Shujie on 11/17/24.
//

import Foundation
import SwiftUI

struct CommentView: View {
    @State private var isProcessingLike = false
    @State private var isProcessingDislike = false
    @State private var errorMessage: String? = nil
    // for reply
    @State private var isShowingReplyInput = false
    @State private var replyTitle = ""
    @State private var replyContent = ""
    @State private var replies: [CommentDTO] = []
    @State private var isLoadingReplies = false
    @State private var hasLoadedReplies = false
    
    let comment: CommentDTO
    let onCommentUpdated: () -> Void
    //let onReply: (CommentDTO) -> Void
    //let loadMoreReplies: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(comment.title)
                .font(.headline)
            Text(comment.content)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                if comment.haveComments {
                    Button("Load More") {
                        loadMoreReplies()
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button("Reply") {
                    isShowingReplyInput = true
                }
                .foregroundColor(.blue)
                
                HStack {
                    Button(action: likeComment) {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text("(\(comment.likes))")
                        }
                    }
                    .disabled(isProcessingLike)
                    
                    Button(action: dislikeComment) {
                        HStack {
                            Image(systemName: "hand.thumbsdown")
                            Text("(\(comment.dislikes))")
                        }
                    }
                    .disabled(isProcessingDislike)
                }
                
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            if !replies.isEmpty {
                ForEach(replies) { reply in
                    CommentView(
                        comment: reply,
                        onCommentUpdated: onCommentUpdated
                    )
                    .padding(.leading, 20)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 5)
        .sheet(isPresented: $isShowingReplyInput) {
            VStack {
                Text("Add Comment")
                    .font(.headline)
                    .padding()
                
                TextField("Reply Title", text: $replyTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Reply Content", text: $replyContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        isShowingReplyInput = false
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Submit") {
                        submitReply()
                        isShowingReplyInput = false
                    }
                    .foregroundColor(.blue)
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    func submitReply() {
        guard let commentId = comment.id?.uuidString else { return }
        
        let newReply = CreateCommentRequest(title: replyTitle, content: replyContent)
        
        CommentService.shared.addReply(to: commentId, comment: newReply) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Reply submitted successfully.")
                    onCommentUpdated()
                case .failure(let error):
                    errorMessage = "Failed to submit reply: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func likeComment() {
        guard let commentId = comment.id?.uuidString else { return }
        //print(commentId)
        isProcessingLike = true
        CommentService.shared.likeComment(commentId: commentId) { result in
            DispatchQueue.main.async {
                isProcessingLike = false
                switch result {
                case .success:
                    //print("Comment liked successfully.")
                    onCommentUpdated()
                case .failure(let error):
                    errorMessage = "Failed to like comment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func dislikeComment() {
        guard let commentId = comment.id?.uuidString else { return }
        //print(commentId)
        isProcessingDislike = true
        CommentService.shared.dislikeComment(commentId: commentId) { result in
            DispatchQueue.main.async {
                isProcessingDislike = false
                switch result {
                case .success:
                    //print("Comment disliked successfully.")
                    onCommentUpdated()
                case .failure(let error):
                    errorMessage = "Failed to dislike comment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadMoreReplies() {
        guard let commentId = comment.id?.uuidString else { return }
        if hasLoadedReplies {
            print("Replies already loaded.")
            return
        }
        isLoadingReplies = true
        errorMessage = nil
        
        CommentService.shared.fetchReplies(for: commentId) { result in
            DispatchQueue.main.async {
                isLoadingReplies = false
                switch result {
                case .success(let fetchedReplies):
                    replies.append(contentsOf: fetchedReplies)
                    hasLoadedReplies = true
                case .failure(let error):
                    errorMessage = "Failed to load replies: \(error.localizedDescription)"
                }
            }
        }
    }
    
}


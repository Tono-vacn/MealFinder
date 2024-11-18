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
    @State private var isRepliesShown = false
    @State private var isShowingDeleteConfirmation = false
    let currentUserId: String
    
    //let comment: CommentDTO
    //@Binding var comment: CommentDTO
    @State private var comment: CommentDTO
    let onCommentUpdated: () -> Void
    //let onReply: (CommentDTO) -> Void
    //let loadMoreReplies: () -> Void
    init(comment: CommentDTO, currentUserId: String, onCommentUpdated: @escaping () -> Void) {
        _comment = State(initialValue: comment)
        self.currentUserId = currentUserId
        self.onCommentUpdated = onCommentUpdated
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(comment.title)
                .font(.headline)
                .padding(.horizontal, 10)
            Text(comment.content)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
            HStack {
                if !isRepliesShown && comment.haveComments {
                    Button("Show replies") {
                        loadMoreReplies()
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if comment.userId?.uuidString == currentUserId{
                    Button("Delete") {
                        //isShowingDeleteConfirmation = true
                        deleteComment()
                    }
                    .foregroundColor(.red)
                }
                
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
            .padding(.horizontal,10)
            .padding(.bottom, 10)
            
            if !replies.isEmpty {
                ForEach(replies) { reply in
                    VStack(alignment: .leading, spacing: 5) {
                        CommentView(
                            comment: reply,
                            currentUserId: currentUserId,
                            onCommentUpdated: onCommentUpdated
                        )

                    }
                }
            }
        }
        .padding(.top, 10)
        .padding(.leading, 5)
        
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.top, 5)
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
        .alert(isPresented: $isShowingDeleteConfirmation) { // Alert for delete confirmation
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this comment?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteComment()
                },
                secondaryButton: .cancel()
            )
            
        }
    }
    
    func submitReply() {
        guard let commentId = comment.id?.uuidString else { return }
        
        let newReply = CreateCommentRequest(title: replyTitle, content: replyContent)
        
        CommentService.shared.addReply(to: commentId, comment: newReply) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.replyTitle = ""
                    self.replyContent = ""
                    self.loadMoreReplies(forceRefresh: true)
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
                case .success(let updatedComment):
                    updateReply(updatedComment)
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
                case .success(let updatedComment):
                    updateReply(updatedComment)
                case .failure(let error):
                    errorMessage = "Failed to dislike comment: \(error.localizedDescription)"
                }
            }
        }
    }

    
    func updateReply(_ updatedComment: CommentDTO) {
        if let index = replies.firstIndex(where: { $0.id == updatedComment.id }) {
            replies[index] = updatedComment
        } else if comment.id == updatedComment.id {
            comment = updatedComment
        }
    }
    
    func loadMoreReplies(forceRefresh: Bool = false) {
        guard let commentId = comment.id?.uuidString else { return }
        if hasLoadedReplies && !forceRefresh {
            isRepliesShown = true
            return
        }
        
        isLoadingReplies = true
        errorMessage = nil
        
        CommentService.shared.fetchReplies(for: commentId) { result in
            DispatchQueue.main.async {
                isLoadingReplies = false
                switch result {
                case .success(let fetchedReplies):
                    self.replies = fetchedReplies
                    hasLoadedReplies = true
                    isRepliesShown = true
                case .failure(let error):
                    errorMessage = "Failed to load replies: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func deleteComment() {
        guard let commentId = comment.id?.uuidString else { return }
        
        CommentService.shared.deleteComment(commentId: commentId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    onCommentUpdated()
                case .failure(let error):
                    errorMessage = "Failed to delete comment: \(error.localizedDescription)"
                }
            }
        }
    }
    
}


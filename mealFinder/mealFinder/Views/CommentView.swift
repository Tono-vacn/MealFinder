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
    let comment: CommentDTO
    
    let onCommentUpdated: () -> Void
    
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
                        //loadMoreReplies()
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button("Reply") {
                    //onReply()
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
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 5)
    }
    
    func likeComment() {
        guard let commentId = comment.id?.uuidString else { return }
        isProcessingLike = true
        CommentService.shared.likeComment(commentId: commentId) { result in
            DispatchQueue.main.async {
                isProcessingLike = false
                switch result {
                case .success:
                    print("Comment liked successfully.")
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
                    print("Comment disliked successfully.")
                    onCommentUpdated()
                case .failure(let error):
                    errorMessage = "Failed to dislike comment: \(error.localizedDescription)"
                }
            }
        }
    }
}


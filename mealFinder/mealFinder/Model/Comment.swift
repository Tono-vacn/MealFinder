//
//  Comment.swift
//  mealFinder
//
//  Created by Shujie on 11/17/24.
//

import Foundation

struct CreateCommentRequest: Codable {
    var title: String
    var content: String
}

struct CommentDTO: Codable, Identifiable {
    var id: UUID?
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var postId: UUID?
    var parentCommentId: UUID?
    var userId: UUID?
    var haveComments: Bool
}

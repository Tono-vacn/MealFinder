//
//  Post.swift
//  mealFinder
//
//  Created by Shujie on 11/5/24.
//

import Foundation

struct Post: Identifiable, Codable {
    var id: String
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var createdAt: String
    var updatedAt: String
    var userId: String?
    var recipe: Recipee?
    var haveComments: Bool
}

struct Recipee: Codable {
    var id: String
    var title: String
    var content: String
    var ingredients: [String]
    var image: String?
}

struct CreatePostRequest: Codable {
    var title: String
    var content: String
    var recipe: CreateRecipeRequest
}


struct CreateRecipeRequest: Codable {
    var title: String
    var content: String
    var ingredients: [String]
    var image: String
}

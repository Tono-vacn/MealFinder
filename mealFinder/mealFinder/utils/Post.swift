//
//  Post.swift
//  mealFinder
//
//  Created by Shujie on 11/5/24.
//

import Foundation


struct CreatePostRequest: Codable {
    var title: String
    var content: String
    var recipe: CreateRecipeRequest
}


struct CreateRecipeRequest: Codable {
    var title: String
    var content: String
    var ingredients: [String]
}

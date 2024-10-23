import Fluent
import Vapor
import Foundation

struct PostDTO: Content {
    var id: UUID?
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var createdAt: Date
    var updatedAt: Date
    var userId: UUID?
    var recipeId: UUID?
}

// extension PostDTO {
//   func toModel() -> Post {
//     return Post(
//       id: self.id,
//       title: self.title,
//       content: self.content,
//       likes: self.likes,
//       dislikes: self.dislikes,
//       createdAt: self.createdAt,
//       updatedAt: self.updatedAt,
//       userId: self.userId,
//       recipeId: self.recipeId
//     )
//   }
// }

struct CreatePostRequest: Content {
    var title: String
    var content: String
    var recipe: CreateRecipeRequest
}
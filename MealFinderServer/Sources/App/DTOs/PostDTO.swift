import Fluent
import Vapor
import Foundation

enum PostOrder: String, Content {
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case likes = "likes"
    // case dislikes = "dislikes"
}

enum PostDirection: String, Content {
    case asc = "asc"
    case desc = "desc"
}

enum PostCreateStatus: String, Content {
    case success = "success"
    case fail = "fail"
}

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
    var haveComments: Bool
}

struct PostDTOInline: Content {
    var id: UUID?
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var createdAt: Date
    var updatedAt: Date
    var userId: UUID?
    var recipe: RecipeDTO
    var haveComments: Bool
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

struct UpdatePostRequest: Content {
    var title: String?
    var content: String?   
}

struct IndexByOrderWithQuantityRequest: Content {
    var order: PostOrder?
    var index: Int?
    var offset: Int?
    var direction: PostDirection?
}

struct CreatePostResponse: Content {
    var status: PostCreateStatus
    var post: PostDTOInline?
}
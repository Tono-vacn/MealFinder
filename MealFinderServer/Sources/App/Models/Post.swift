import Fluent
import Foundation
import Vapor

final class Post: Model, @unchecked Sendable {
  static let schema = "posts"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Field(key: "content")
  var content: String

  // @Field(key: "likes")
  // var likes: Int

  // @Field(key: "dislikes")
  // var dislikes: Int

  @Siblings(through: PostUserLike.self, from: \.$post, to: \.$user)
  var likes: [User]

  @Field(key: "likes_count")
  var likesCount: Int

  @Siblings(through: PostUserDislike.self, from: \.$post, to: \.$user)
  var dislikes: [User]

  @Field(key: "dislikes_count")
  var dislikesCount: Int

  @Field(key: "created_at")
  var createdAt: Date

  @Field(key: "updated_at")
  var updatedAt: Date

  @OptionalParent(key: "user_id")
  var user: User?

  @OptionalParent(key: "recipe_id")
  var recipe: Recipe?

  @Children(for: \.$post)
  var comments: [Comment]


  init() { }

  init(id: UUID? = nil, title: String, content: String, createdAt: Date, updatedAt: Date, userId: UUID? = nil, recipeId: UUID? = nil) {
    self.id = id
    self.title = title
    self.content = content
    // self.likes = []
    // self.dislikes = []
    self.likesCount = 0
    self.dislikesCount = 0
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    // self.$user.id = userId
    // self.$recipe.id = recipeId
    if let userId = userId {
      self.$user.id = userId
    }
    if let recipeId = recipeId {
      self.$recipe.id = recipeId
    }
  }

}

extension Post {
    func hasComments(on db: Database) async throws -> Bool {
        let count = try await $comments.query(on: db).count()
        return count > 0
    }

    func toDTO(on db: Database) async throws -> PostDTO {
        let haveComments = try await self.hasComments(on: db)
        return PostDTO(
            id: self.id,
            title: self.title,
            content: self.content,
            likes: self.likesCount,
            dislikes: self.dislikesCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            userId: self.$user.id,
            recipeId: self.$recipe.id,
            haveComments: haveComments
        )
    }

    func toDTOInline(on db: Database) async throws -> PostDTOInline {
        guard let recipe = try await self.$recipe.query(on: db).first() else {
            throw Abort(.internalServerError)
        }
        let haveComments = try await self.hasComments(on: db)
        return PostDTOInline(
            id: self.id,
            title: self.title,
            content: self.content,
            likes: self.likesCount,
            dislikes: self.dislikesCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            userId: self.$user.id,
            recipe: recipe.toDTO(),
            haveComments: haveComments
        )
    }
}
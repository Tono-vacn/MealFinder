import Fluent
import Foundation

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
    self.likes = []
    self.dislikes = []
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
    func toDTO() -> PostDTO {
        return PostDTO(
            id: self.id,
            title: self.title,
            content: self.content,
            likes: self.likesCount,
            dislikes: self.dislikesCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            userId: self.$user.id,
            recipeId: self.$recipe.id
        )
    }
}
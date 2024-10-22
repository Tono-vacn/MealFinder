import Fluent
import Vapor

final class Recipe: Model, @unchecked Sendable {

  static let schema = "recipes"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Field(key: "content")
  var content: String

  @Field(key: "ingredients")
  var ingredients: [String] // not sure if this should be a string or an array of strings

  @Children(for: \.$recipe)
  var posts: [Post]

  init() { }

  init(id: UUID? = nil, title: String, content: String, ingredients: [String]) {
    self.id = id
    self.title = title
    self.content = content
    self.ingredients = ingredients
  }
}
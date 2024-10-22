import Vapor
import Fluent 

struct RecipeDTO: Content {
    var id: UUID?
    var title: String
    var content: String
    var ingredients: [String]

    func toModel() -> Recipe {
        return Recipe(
            id: self.id,
            title: self.title,
            content: self.content,
            ingredients: self.ingredients
        )
    }
}
import Fluent
import Vapor

// struct PostController: RouteCollection {
//     func boot(routes: RoutesBuilder) throws {
//         let recipes = routes.grouped("posts")
//         recipes.get(use: index)
//         // recipes.post(use: create)
//         recipes.group(":recipeID") { recipe in
//             recipe.delete(use: delete)
//         }

//         let tokenProtected = recipes.grouped(UserToken.authenticator(), User.guardMiddleware())
//         tokenProtected.post(use: create)
        

//     }
    
//     @Sendable
//     func index(req: Request) async throws -> [PostDTO] {
//         try await Post.query(on: req.db).all().map { $0.toDTO() }
//     } 

//     @Sendable
//     func create(req: Request) async throws -> RecipeDTO {
//         let recipe = try req.content.decode(RecipeDTO.self).toModel()
//         try await recipe.save(on: req.db)
//         return recipe.toDTO()
//     }

//     @Sendable
//     func delete(req: Request) async throws -> HTTPStatus {
//         guard let recipe = try await Recipe.find(req.parameters.get("recipeID"), on: req.db) else {
//             throw Abort(.notFound)
//         }
//         try await recipe.delete(on: req.db)
//         return .noContent
//     }
// }
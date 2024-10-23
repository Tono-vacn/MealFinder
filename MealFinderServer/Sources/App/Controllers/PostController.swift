import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recipes = routes.grouped("posts")
        recipes.get(use: index)
        // recipes.post(use: create)
        recipes.group(":postID") { recipe in
            // recipe.delete(use: delete)
        }

        let tokenProtected = recipes.grouped(UserToken.authenticator(), User.guardMiddleware())
        tokenProtected.post(use: create)
        

    }

    @Sendable
    func index(req: Request) async throws -> [PostDTO] {
        try await Post.query(on: req.db).all().map { $0.toDTO() }
    } 

    @Sendable
    func create(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        let rawPost = try req.content.decode(CreatePostRequest.self)
        let recipe = Recipe(title: rawPost.recipe.title, content: rawPost.recipe.content, ingredients: rawPost.recipe.ingredients)
        try await recipe.save(on: req.db)
        let post = Post(title: rawPost.title, content: rawPost.content, createdAt: Date(), updatedAt: Date(), userId: curUser.id, recipeId: recipe.id)
        try await post.save(on: req.db)
        return .created
    } 

//     @Sendable
//     func delete(req: Request) async throws -> HTTPStatus {
//         guard let recipe = try await Recipe.find(req.parameters.get("recipeID"), on: req.db) else {
//             throw Abort(.notFound)
//         }
//         try await recipe.delete(on: req.db)
//         return .noContent
//     }
}
import Fluent
import Vapor

struct CreatePost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("posts")
            .id()
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .field("recipe_id", .uuid, .references("recipes", "id", onDelete: .cascade))
            .field("likes_count", .int)
            .field("dislikes_count", .int)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("posts").delete()
    }
}
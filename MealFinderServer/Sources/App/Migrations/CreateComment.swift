import Fluent
import Vapor

struct CreateComment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("comments")
            .id()
            .field("likes_count", .int)
            .field("dislikes_count", .int)
            .field("post_id", .uuid, .references("posts", "id", onDelete: .cascade))
            .field("parent_comment_id", .uuid, .references("comments", "id", onDelete: .cascade))
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .field("content", .string)
            .field("title", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("comments").delete()
    }
}
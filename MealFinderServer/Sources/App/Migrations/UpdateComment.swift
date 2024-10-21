import Fluent
import Vapor

struct UpdateComment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("comments")
            .id()
            .field("likes", .int)
            .field("dislikes", .int)
            .field("parent_comment_id", .uuid, .references("comments", "id"))
            .field("user_id", .uuid, .references("users", "id"))
            .field("content", .string)
            .field("title", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("comments")
            .deleteField("likes")
            .deleteField("dislikes")
            .deleteField("parent_comment_id")
            .deleteField("user_id")
            .update()
    }
}
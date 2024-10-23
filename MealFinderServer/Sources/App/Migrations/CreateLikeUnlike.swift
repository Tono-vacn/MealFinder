import Vapor
import Fluent

struct CreatePostUserLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("post_user_likes")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("post_user_likes").delete()
    }
}

struct CreateCommentUserLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("comment_user_likes")
            .id()
            .field("comment_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("comment_user_likes").delete()
    }
}
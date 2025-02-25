import Fluent
import Vapor

struct CreateUserToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserToken.schema)
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .unique(on: "value")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserToken.schema).delete()
    }
}

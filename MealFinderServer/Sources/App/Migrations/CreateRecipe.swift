import Fluent
import Vapor

struct CreateRecipe: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("recipes")
            .id()
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("ingredients", .array(of: .string), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("recipes").delete()
    }
}
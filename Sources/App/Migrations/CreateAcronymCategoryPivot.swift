import Fluent

final class CreateAcronymCategoryPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(AcronymCategoryPivot.schema)
            .id()
            .field("acronymID", .uuid, .required, .references(Acronym.schema, "id", onDelete: .cascade))
            .field("categoryID", .uuid, .required, .references(Category.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(AcronymCategoryPivot.schema)
            .delete()
    }
}

import Fluent

struct CreateQuestion: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("questions")
      .id()
      .field("body", .string, .required)
      .field("solved", .bool, .required)
      .field("created_at", .datetime, .required)
      .field("updated_at", .datetime)
      .field("deleted_at", .datetime)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("questions").delete()
  }
}

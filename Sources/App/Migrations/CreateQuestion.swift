import Fluent

struct CreateQuestion: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.enum("category")
      .case("technology")
      .case("geography")
      .case("food")
      .case("literature")
      .case("animals")
      .case("science")
      .case("music")
      .case("generalKnowledge")
      .case("history")
      .case("arts")
      .case("sports")
      .case("entertainment")
      .create()

    let category = try await database.enum("category").read()
    try await database.schema("questions")
      .id()
      .field("body", .string, .required)
      .field("solved", .bool, .required)
      .field("category", category, .required)
      .field("created_at", .datetime, .required)
      .field("updated_at", .datetime)
      .field("deleted_at", .datetime)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("questions").delete()
    try await database.enum("category").delete()
  }
}

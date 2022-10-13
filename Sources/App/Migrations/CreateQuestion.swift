import Fluent

struct CreateQuestion: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.enum("category")
      .case("Technology")
      .case("Geography")
      .case("Food")
      .case("Literature")
      .case("Animals")
      .case("Science")
      .case("Music")
      .case("General Knowledge")
      .case("History")
      .case("Arts")
      .case("Sports")
      .case("Entertainment")
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

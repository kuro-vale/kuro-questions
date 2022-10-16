import Fluent

struct CreateUser: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("users")
      .id()
      .field("username", .string, .required)
      .field("password", .string, .required)
      .field("created_at", .datetime, .required)
      .field("updated_at", .datetime)
      .field("deleted_at", .datetime)
      .unique(on: "username")
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("users").delete()
  }
}

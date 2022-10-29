import Fluent

struct CreateAnswer: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("answers")
      .id()
      .field("body", .string, .required)
      .field("user_id", .uuid, .required)
      .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
      .field("question_id", .uuid, .required)
      .foreignKey("question_id", references: "questions", "id", onDelete: .cascade)
      .field("created_at", .datetime, .required)
      .field("updated_at", .datetime)
      .field("deleted_at", .datetime)
      .create()

    try await database.schema("votes")
      .id()
      .field("upvote", .bool, .required)
      .field("user_id", .uuid, .required)
      .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
      .field("answer_id", .uuid, .required)
      .foreignKey("answer_id", references: "answers", "id", onDelete: .cascade)
      .unique(on: "user_id", "answer_id")
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("votes").delete()
    try await database.schema("answers").delete()
  }
}

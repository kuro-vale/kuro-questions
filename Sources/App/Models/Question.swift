import Fluent
import Vapor

final class Question: Model, Content {
  static let schema = "questions"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "body")
  var body: String

  @Field(key: "solved")
  var solved: Bool

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @Timestamp(key: "deleted_at", on: .delete)
  var deletedAt: Date?

  init() {}

  init(body: String) {
    self.body = body
    self.solved = false
  }
}

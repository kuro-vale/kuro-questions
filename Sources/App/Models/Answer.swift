import Fluent
import Vapor

final class Answer: Model {
  static let schema = "answers"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "question_id")
  var question: Question

  @Parent(key: "user_id")
  var user: User

  @Field(key: "body")
  var body: String

  @Children(for: \.$answer)
  var voters: [Voter]

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @Timestamp(key: "deleted_at", on: .delete)
  var deletedAt: Date?

  init() {}

  init(_ body: String, _ questionId: UUID, _ userId: UUID) {
    self.body = body
    self.$question.id = questionId
    self.$user.id = userId
  }
}

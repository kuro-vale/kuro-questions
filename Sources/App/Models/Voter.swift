import Fluent
import Vapor

final class Voter: Model {
  static let schema = "voters"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "answer_id")
  var answer: Answer

  @Field(key: "upvote")
  var upvote: Bool

  init() {}

  init(userId: UUID, answerId: UUID, upvote: Bool) {
    self.$user.id = userId
    self.$answer.id = answerId
    self.upvote = upvote
  }
}

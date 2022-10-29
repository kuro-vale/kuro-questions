import Fluent
import Vapor

/// Database vote model
final class Vote: Model {
  static let schema = "votes"

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

/// Vote model for HTTP responses
struct VoteResponse: Content {
  var username: String
}

import Fluent
import Vapor

/// Database answer model
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
  var votes: [Vote]

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

/// Answer model for HTTP requests
struct AnswerRequest: Content {
  var body: String
}

extension AnswerRequest: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("body", as: String.self, is: !.empty)
    validations.add("body", as: String.self, is: .count(3...1000))
  }
}

/// Answer model for HTTP responses
struct AnswerResponse: Content {
  var id: String
  var body: String
  var upvotes: Int
  var downvotes: Int
  var createdAt: String
  var updatedAt: String?
  var createdBy: String
  var url: String
  var questionUrl: String
}

/// Answer response model with pagination metadata
struct PaginatedAnswers: Content {
  var items: [AnswerResponse]
  var metadata: ServerMetadata
}

/// Generate an `AnswerResponse`
func answerAssembler(_ answer: Answer) -> AnswerResponse {
  // Count votes
  let upvotes = answer.votes.filter { vote in vote.upvote == true }.count
  let downvotes = answer.votes.filter { vote in vote.upvote == false }.count
  // Generate response metadata
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .long
  dateFormatter.timeStyle = .short

  var updatedAt: String? = dateFormatter.string(from: answer.updatedAt!)
  if answer.createdAt == answer.updatedAt {
    updatedAt = nil
    answer.updatedAt = nil
  }

  return AnswerResponse(
    id: "\(answer.id!)", body: answer.body, upvotes: upvotes, downvotes: downvotes,
    createdAt: dateFormatter.string(from: answer.createdAt!), updatedAt: updatedAt,
    createdBy: answer.user.username, url: "\(host)/answers/\(answer.id!)",
    questionUrl: "\(host)/questions/\(answer.question.id!)"
  )
}

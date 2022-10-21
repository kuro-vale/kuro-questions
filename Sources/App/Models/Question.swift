import Fluent
import Vapor

final class Question: Model {
  static let schema = "questions"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Field(key: "body")
  var body: String

  @Field(key: "solved")
  var solved: Bool

  @Enum(key: "category")
  var category: Category

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @Timestamp(key: "deleted_at", on: .delete)
  var deletedAt: Date?

  init() {}

  init(_ body: String, _ category: Category, _ userId: UUID) {
    self.body = body
    self.solved = false
    self.category = category
    self.$user.id = userId
  }
}

struct QuestionRequest: Content {
  var body: String
  var category: Category
}

extension QuestionRequest: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("body", as: String.self, is: !.empty)
    validations.add("body", as: String.self, is: .count(3...255))
    validations.add(
      "category", as: String.self,
      is: .in(
        "Technology", "Geography", "Food", "Literature", "Animals", "Science", "Music",
        "General Knowledge", "History", "Arts", "Sports", "Entertainment"),
      required: true
    )
  }
}

struct QuestionResponse: Content {
  var id: String
  var body: String
  var category: String
  var solved: Bool
  var created_at: String
  var updated_at: String?
  var url: String
}

struct PaginatedQuestions: Content {
  var items: [QuestionResponse]
  var metadata: ServerMetadata
}

func QuestionAssembler(_ question: Question) -> QuestionResponse {
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .long
  dateFormatter.timeStyle = .short

  var updated_at: String? = dateFormatter.string(from: question.updatedAt!)
  if question.createdAt == question.updatedAt {
    updated_at = nil
    question.updatedAt = nil
  }

  return QuestionResponse(
    id: "\(question.id!)", body: question.body, category: question.category.rawValue,
    solved: question.solved, created_at: dateFormatter.string(from: question.createdAt!),
    updated_at: updated_at,
    url: "\(host)/questions/\(question.id!)")
}

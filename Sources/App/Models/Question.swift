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

  @Enum(key: "category")
  var category: Category

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @Timestamp(key: "deleted_at", on: .delete)
  var deletedAt: Date?

  init() {}

  init(_ body: String, _ category: Category) {
    self.body = body
    self.solved = false
    self.category = category
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
  var updated_at: String
  var url: String
}

func QuestionAssembler(_ question: Question) -> QuestionResponse {
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .long
  dateFormatter.timeStyle = .short

  return QuestionResponse(
    id: "\(question.id!)", body: question.body, category: question.category.rawValue,
    solved: question.solved, created_at: dateFormatter.string(from: question.createdAt!),
    updated_at: dateFormatter.string(from: question.createdAt!),
    url: "\(host)/questions/\(question.id!)")
}

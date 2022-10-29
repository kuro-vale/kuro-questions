import Fluent
import Vapor

/// Retrieve and authorize a question
///
/// - Throws: `.forbidden`
///           if `question` doesn't belong to user
///
/// - Returns: user's question.
func getAuthorizedQuestion(req: Request) async throws -> Question {
  let user = try req.auth.require(User.self)
  // Fetch database
  guard let question = try await Question.find(req.parameters.get("questionID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  // Lazy Eager Load
  try await question.$user.load(on: req.db)
  // Authorize request
  if question.$user.id != user.id {
    throw Abort(.forbidden)
  }
  return question
}

/// Query all questions by body and category
///
/// - Parameter user: filter questions by user
/// - Returns: assembled response and page metadata
func queryQuestions(_ req: Request, _ user: User? = nil) async throws -> (
  PageMetadata, [QuestionResponse]
) {
  // Get Query
  let body = req.query["q"] ?? ""
  let query: QueryBuilder<Question>
  if user != nil {
    query = user!.$questions.query(on: req.db).with(\.$user)
  } else {
    query = Question.query(on: req.db).with(\.$user)
  }
  query.filter(\.$body, .custom("ilike"), "%\(body)%")
  if let category = Category.init(rawValue: req.query["category"] ?? "") {
    query.filter(\.$category == category)
  }
  // Fetch Database
  let questions = try await query.paginate(
    PageRequest(page: req.query["page"] ?? 1, per: 10))
  // Generate Response
  var response: [QuestionResponse] = []
  for question in questions.items {
    response.append(questionAssembler(question))
  }
  return (questions.metadata, response)
}

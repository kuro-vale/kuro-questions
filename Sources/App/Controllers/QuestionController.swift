import Fluent
import Vapor

struct QuestionController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let questions = routes.grouped("questions")
    questions.get(use: index)
    questions.post(use: create)
    questions.group(":questionID") { question in
      question.delete(use: delete)
    }
  }

  func index(req: Request) async throws -> PaginatedQuestions {
    let questions = try await Question.query(on: req.db).filter(\.$solved == false).paginate(
      PageRequest(page: req.query["page"] ?? 1, per: 10))
    var response: [QuestionResponse] = []
    for question in questions.items {
      response.append(QuestionAssembler(question))
    }
    return PaginatedQuestions(
      items: response, metadata: QuestionMetadataAssembler(questions.metadata))
  }

  func create(req: Request) async throws -> QuestionResponse {
    try QuestionRequest.validate(content: req)
    let request = try req.content.decode(QuestionRequest.self)
    let question = Question(request.body, request.category)
    try await question.save(on: req.db)
    let response = QuestionAssembler(question)
    return response
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let question = try await Question.find(req.parameters.get("questionID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    try await question.delete(on: req.db)
    return .noContent
  }
}

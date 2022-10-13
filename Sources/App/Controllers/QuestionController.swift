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

  func index(req: Request) async throws -> [QuestionResponse] {
    let questions = try await Question.query(on: req.db).all()
    var response: [QuestionResponse] = []
    for question in questions {
      response.append(QuestionAssembler(question))
    }
    return response
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

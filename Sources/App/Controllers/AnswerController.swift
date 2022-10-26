import Fluent
import Vapor

struct AnswerController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let questions = routes.grouped("questions")
    questions.group(":questionID") { question in
      question.get("answers", use: index)
    }
  }

  // GET /questions/:id/answers
  func index(req: Request) async throws -> PaginatedAnswers {
    // Get Question
    guard let question = try await Question.find(req.parameters.get("questionID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Fetch Database
    let answers = try await question.$answers.query(on: req.db).with(\.$user).with(\.$question)
      .with(\.$voters)
      .paginate(
        PageRequest(page: req.query["page"] ?? 1, per: 10))
    // Generate Response
    var response: [AnswerResponse] = []
    for answer in answers.items {
      try await response.append(answerAssembler(answer))
    }
    return PaginatedAnswers(
      items: response, metadata: serverMetadataAssembler(answers.metadata, path: req.url.path))
  }
}

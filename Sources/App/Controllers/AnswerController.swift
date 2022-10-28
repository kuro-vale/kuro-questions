import Fluent
import Vapor

struct AnswerController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let questions = routes.grouped("questions")
    questions.group(":questionID") { question in
      question.get("answers", use: index)
    }

    let answers = routes.grouped("answers")
    answers.group(":answerID") { answer in
      answer.get(use: getOne)
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
      response.append(answerAssembler(answer))
    }
    return PaginatedAnswers(
      items: response, metadata: serverMetadataAssembler(answers.metadata, path: req.url.path))
  }

  // GET /answers/:id
  func getOne(req: Request) async throws -> AnswerResponse {
    guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Lazy Eager Load
    try await answer.$user.load(on: req.db)
    try await answer.$question.load(on: req.db)
    try await answer.$voters.load(on: req.db)
    return answerAssembler(answer)
  }
}

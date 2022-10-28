import Fluent
import Vapor

struct AnswerController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let questions = routes.grouped("questions")
    questions.group(":questionID") { question in
      let authorized = question.grouped(JWTAuthenticator())
      // Routes
      question.get("answers", use: index)
      authorized.post("answers", use: create)
    }
    let answers = routes.grouped("answers")
    answers.group(":answerID") { answer in
      let authorized = answer.grouped(JWTAuthenticator())
      // Routes
      answer.get(use: getOne)
      authorized.put(use: update)
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

  // POST /questions/:id/answers
  func create(req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    // Get Question
    guard let question = try await Question.find(req.parameters.get("questionID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Validate Request
    try AnswerRequest.validate(content: req)
    let request = try req.content.decode(AnswerRequest.self)
    // Create Answer
    let answer = Answer(request.body, question.id!, user.id!)
    try await answer.save(on: req.db)
    // Lazy Eager Load
    try await answer.$user.load(on: req.db)
    try await answer.$question.load(on: req.db)
    try await answer.$voters.load(on: req.db)
    let response = answerAssembler(answer)
    return try await response.encodeResponse(status: .created, for: req)
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

  // PUT /answers/:id
  func update(req: Request) async throws -> AnswerResponse {
    let user = try req.auth.require(User.self)
    guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Lazy Eager Load
    try await answer.$user.load(on: req.db)
    try await answer.$question.load(on: req.db)
    try await answer.$voters.load(on: req.db)
    // Authorize request
    if answer.user.id != user.id {
      throw Abort(.forbidden)
    }
    // Validate Request
    try AnswerRequest.validate(content: req)
    let request = try req.content.decode(AnswerRequest.self)
    // Update answer
    answer.body = request.body
    try await answer.update(on: req.db)
    return answerAssembler(answer)
  }
}

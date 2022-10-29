import Fluent
import Vapor

struct QuestionController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let questions = routes.grouped("questions")
    let authorized = questions.grouped(JWTAuthenticator())
    // Routes
    questions.get(use: index)
    questions.get("search", use: search)
    authorized.get("me", use: userQuestions)
    authorized.post(use: create)
    questions.group(":questionID") { question in
      let authorized = question.grouped(JWTAuthenticator())
      // Routes
      question.get(use: getOne)
      authorized.put(use: update)
      authorized.delete(use: delete)
      authorized.patch(use: resolve)
    }
  }

  // GET /questions
  func index(req: Request) async throws -> PaginatedQuestions {
    // Fetch Database
    let questions = try await Question.query(on: req.db).with(\.$user).filter(\.$solved == false)
      .paginate(
        PageRequest(page: req.query["page"] ?? 1, per: 10))
    // Generate Response
    var response: [QuestionResponse] = []
    for question in questions.items {
      response.append(questionAssembler(question))
    }
    return PaginatedQuestions(
      items: response, metadata: serverMetadataAssembler(questions.metadata, path: req.url.path))
  }

  // GET /questions/search?q=&category=
  func search(req: Request) async throws -> PaginatedQuestions {
    let (metadata, response) = try await queryQuestions(req)
    return PaginatedQuestions(
      items: response,
      metadata: serverMetadataAssembler(
        metadata, path: req.url.path, query: req.url.query ?? ""))
  }

  // GET /questions/me
  func userQuestions(req: Request) async throws -> PaginatedQuestions {
    let user = try req.auth.require(User.self)
    let (metadata, response) = try await queryQuestions(req, user)
    return PaginatedQuestions(
      items: response,
      metadata: serverMetadataAssembler(
        metadata, path: req.url.path, query: req.url.query ?? ""))
  }

  // GET /questions/:id
  func getOne(req: Request) async throws -> QuestionResponse {
    guard let question = try await Question.find(req.parameters.get("questionID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Lazy Eager Load
    try await question.$user.load(on: req.db)
    return questionAssembler(question)
  }

  // POST /questions
  func create(req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    // Validate Request
    try QuestionRequest.validate(content: req)
    let request = try req.content.decode(QuestionRequest.self)
    // Create Question
    let question = Question(request.body, request.category, user.id!)
    try await question.save(on: req.db)
    // Lazy Eager Load
    try await question.$user.load(on: req.db)
    let response = questionAssembler(question)
    return try await response.encodeResponse(status: .created, for: req)
  }

  // PUT /questions/:id
  func update(req: Request) async throws -> QuestionResponse {
    let question = try await getAuthorizedQuestion(req: req)
    // Validate Request
    try QuestionRequest.validate(content: req)
    let request = try req.content.decode(QuestionRequest.self)
    // Update Question
    question.body = request.body
    question.category = request.category
    try await question.update(on: req.db)
    return questionAssembler(question)
  }

  // DELETE /questions/:id
  func delete(req: Request) async throws -> HTTPStatus {
    let question = try await getAuthorizedQuestion(req: req)
    try await question.delete(on: req.db)
    return .noContent
  }

  // PATCH /questions/:id
  func resolve(req: Request) async throws -> QuestionResponse {
    let question = try await getAuthorizedQuestion(req: req)
    if question.solved {
      throw Abort(.badRequest, reason: "question already solved")
    }
    // Resolve Question
    question.solved = true
    try await question.update(on: req.db)
    return questionAssembler(question)
  }
}

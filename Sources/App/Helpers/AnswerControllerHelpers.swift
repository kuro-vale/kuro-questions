import Fluent
import Vapor

func AnswerLazyEagerLoad(_ answer: Answer, _ req: Request) async throws {
  try await answer.$user.load(on: req.db)
  try await answer.$question.load(on: req.db)
  try await answer.$voters.load(on: req.db)
}

func getAuthorizedAnswer(_ req: Request) async throws -> Answer {
  let user = try req.auth.require(User.self)
  // Get Answer
  guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  try await AnswerLazyEagerLoad(answer, req)
  // Authorize request
  if answer.user.id != user.id {
    throw Abort(.forbidden)
  }
  return answer
}

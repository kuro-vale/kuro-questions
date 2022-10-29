import Fluent
import Vapor

/// Load answer children (user, question and votes)
func answerLazyEagerLoad(_ answer: Answer, _ req: Request) async throws {
  try await answer.$user.load(on: req.db)
  try await answer.$question.load(on: req.db)
  try await answer.$votes.load(on: req.db)
}

/// Retrieve and authorize an answer
///
/// - Throws: `.forbidden`
///           if `answer` doesn't belong to user
///
/// - Returns: user's answer.
func getAuthorizedAnswer(_ req: Request) async throws -> Answer {
  let user = try req.auth.require(User.self)
  // Get Answer
  guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  try await answerLazyEagerLoad(answer, req)
  // Authorize request
  if answer.user.id != user.id {
    throw Abort(.forbidden)
  }
  return answer
}

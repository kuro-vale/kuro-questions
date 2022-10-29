import Fluent
import Vapor

func createVote(upvote: Bool, req: Request) async throws -> HTTPStatus {
  let user = try req.auth.require(User.self)
  // Get Answer
  guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  // Create Vote
  let upvote = Voter(userId: user.id!, answerId: answer.id!, upvote: upvote)
  do {
    try await upvote.save(on: req.db)
  } catch {
    throw Abort(.badRequest)
  }
  return .created
}

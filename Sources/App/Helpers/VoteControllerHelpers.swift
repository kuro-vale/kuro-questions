import Fluent
import Vapor

func createVote(upvote: Bool, req: Request) async throws -> HTTPStatus {
  let user = try req.auth.require(User.self)
  // Get Answer
  guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  // Try to get previous vote
  if let vote = try await Vote.query(on: req.db).filter(\.$user.$id == user.id!).filter(
    \.$answer.$id == answer.id!
  ).first() {
    try await vote.delete(on: req.db)
  }
  // Create Vote
  let upvote = Vote(userId: user.id!, answerId: answer.id!, upvote: upvote)
  do {
    try await upvote.save(on: req.db)
  } catch {
    throw Abort(.badRequest)
  }
  return .created
}

func getVotes(upvote: Bool, req: Request) async throws -> [VoteResponse] {
  // Get Answer
  guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
  else {
    throw Abort(.notFound)
  }
  let upvotes = try await answer.$votes.query(on: req.db).filter(\.$upvote == upvote).all()
  // Generate response
  var response: [VoteResponse] = []
  for upvote in upvotes {
    try await upvote.$user.load(on: req.db)
    response.append(VoteResponse(username: upvote.user.username))
  }
  return response
}

import Fluent
import Vapor

struct VoteController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let answers = routes.grouped("answers")
    answers.group(":answerID") { answer in
      answer.group("upvotes") { upvote in
        let authorized = upvote.grouped(JWTAuthenticator())
        // Routes
        upvote.get(use: getUpvotes)
        authorized.post(use: createUpvote)
        authorized.delete(use: deleteVote)
      }
      answer.group("downvotes") { downvote in
        let authorized = downvote.grouped(JWTAuthenticator())
        // Routes
        downvote.get(use: getDownvotes)
        authorized.post(use: createDownvote)
        authorized.delete(use: deleteVote)
      }
    }
  }

  // POST /answers/:id/upvotes
  func createUpvote(req: Request) async throws -> HTTPStatus {
    try await createVote(upvote: true, req: req)
  }

  // GET /answers/:id/upvotes
  func getUpvotes(req: Request) async throws -> [VoteResponse] {
    try await getVotes(upvote: true, req: req)
  }

  // GET /answers/:id/downvotes
  func getDownvotes(req: Request) async throws -> [VoteResponse] {
    try await getVotes(upvote: false, req: req)
  }

  // POST /answers/:id/downvotes
  func createDownvote(req: Request) async throws -> HTTPStatus {
    try await createVote(upvote: false, req: req)
  }

  // DELETE /answer/:id/upvotes or DELETE /answer/:id/downvotes
  func deleteVote(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    // Get Answer
    guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Get Vote
    guard
      let vote = try await Vote.query(on: req.db).filter(\.$user.$id == user.id!).filter(
        \.$answer.$id == answer.id!
      ).first()
    else {
      throw Abort(.notFound)
    }
    try await vote.delete(on: req.db)
    return .noContent
  }
}

import Fluent
import Vapor

struct VoteAnswerController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let authorized = routes.grouped(JWTAuthenticator())
    let answers = authorized.grouped("answers")
    answers.group(":answerID") { answer in
      answer.group("upvotes") { upvote in
        // Routes
        upvote.post(use: createUpvote)
        upvote.delete(use: deleteVote)
      }
      answer.group("downvotes") { downvote in
        // Routes
        downvote.post(use: createDownvote)
        downvote.delete(use: deleteVote)
      }
    }
  }

  // POST /answers/:id/upvotes
  func createUpvote(req: Request) async throws -> HTTPStatus {
    return try await createVote(upvote: true, req: req)
  }

  // POST /answers/:id/downvotes
  func createDownvote(req: Request) async throws -> HTTPStatus {
    return try await createVote(upvote: false, req: req)
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

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
      }
      answer.group("downvotes") { downvote in
        // Routes
      }
    }
  }

  // POST /answers/:id/upvotes
  func createUpvote(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    // Get Answer
    guard let answer = try await Answer.find(req.parameters.get("answerID"), on: req.db)
    else {
      throw Abort(.notFound)
    }
    // Create Vote
    let upvote = Voter(userId: user.id!, answerId: answer.id!, upvote: true)
    do {
      try await upvote.save(on: req.db)
    } catch {
      throw Abort(.badRequest)
    }
    return .created
  }
}

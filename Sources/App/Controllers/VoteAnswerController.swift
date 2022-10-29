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
        downvote.post(use: createDownvote)
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
}

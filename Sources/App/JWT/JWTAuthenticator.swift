import Fluent
import Vapor

/// Verify JWT token in Authorization header
struct JWTAuthenticator: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let payload = try request.jwt.verify(as: SessionToken.self)
    if let user = try await User.query(on: request.db).filter(\.$id == payload.userId).first() {
      request.auth.login(user)
    }
    return try await next.respond(to: request)
  }
}

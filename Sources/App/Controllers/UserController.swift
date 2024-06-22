import Fluent
import Vapor

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let users = routes.grouped("auth")
    users.post("register", use: register)
    users.post("login", use: login)
    let authorized = users.grouped(JWTAuthenticator())
    authorized.get("me", use: current)
  }

  // POST /auth/register
  func register(req: Request) async throws -> Response {
    try UserRequest.validate(content: req)
    let request = try req.content.decode(UserRequest.self)
    let user = try User(request.username, request.password)
    do {
      try await user.save(on: req.db)
    } catch {
      throw Abort(.badRequest, reason: "username already taken")
    }
    let payload = SessionToken(userId: user.id!, username: user.username)
    let response = userAssembler(user, token: try req.jwt.sign(payload))
    return try await response.encodeResponse(status: .created, for: req)
  }

  // POST /auth/login
  func login(req: Request) async throws -> UserResponse {
    try UserRequest.validate(content: req)
    let request = try req.content.decode(UserRequest.self)
    if let user = try await User.query(on: req.db).filter(\.$username == request.username).first() {
      if try Bcrypt.verify(request.password, created: user.password) {
        let payload = SessionToken(userId: user.id!, username: user.username)
        let response = userAssembler(user, token: try req.jwt.sign(payload))
        return response
      }
    }
    throw Abort(.unauthorized, reason: "invalid credentials")
  }

  // GET /auth/me
  func current(req: Request) async throws -> CurrentUser {
    let user = try req.auth.require(User.self)
    return CurrentUser(id: user.id!, username: user.username)
  }
}

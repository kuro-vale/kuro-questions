import JWT
import Vapor

struct SessionToken: Content, Authenticatable, JWTPayload {
  // Token Data
  var expiration: ExpirationClaim
  var userId: UUID
  var username: String

  // 1_296_000 are 15 days in seconds
  init(userId: UUID, username: String, expirationTime: TimeInterval = 1_296_000) {
    self.userId = userId
    self.username = username
    self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
  }

  func verify(using signer: JWTSigner) throws {
    try expiration.verifyNotExpired()
  }
}

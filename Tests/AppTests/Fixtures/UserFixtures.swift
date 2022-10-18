import Fluent

@testable import App

func newUser(
  _ username: String = "testuser", _ password: String = "password", on database: Database
) throws -> User {
  let user = try User(username, password)
  try user.save(on: database).wait()
  return user
}

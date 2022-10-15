import Fluent
import Vapor

final class User: Model {
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "username")
  var username: String

  @Field(key: "password")
  var password: String

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  @Timestamp(key: "deleted_at", on: .delete)
  var deletedAt: Date?

  init() {}

  init(_ username: String, _ password: String) throws {
    self.username = username
    self.password = try Bcrypt.hash(password)
  }
}

struct UserResponse: Content {
  var username: String
  var token: String
}

struct UserRequest: Content {
  var username: String
  var password: String
}

extension UserRequest: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: .count(3...18) && .alphanumeric)
    validations.add("password", as: String.self, is: .count(5...10) && .alphanumeric)
  }
}

struct CurrentUser: Authenticatable {
  var username: String
}

func UserAssembler(_ user: User) -> UserResponse {
  return UserResponse(username: user.username, token: "TOKEN")
}

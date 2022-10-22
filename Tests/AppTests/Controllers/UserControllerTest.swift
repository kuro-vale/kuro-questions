import XCTVapor

@testable import App

final class UserControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // POST /auth/login
  func testLogin() throws {
    let user = try newUser(on: app.db)

    try app.test(
      .POST, "auth/login",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: user.username, password: "password"))
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(UserResponse.self)
        XCTAssertEqual(response.username, user.username)
      })
  }

  // POST /auth/register
  func testRegister() throws {
    try app.test(
      .POST, "auth/register",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: "foo", password: "bar123"))
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .created)
        let response = try res.content.decode(UserResponse.self)
        XCTAssertEqual(response.username, "foo")
      }
    )

    // Status code 400 if user already exists
    try app.test(
      .POST, "auth/register",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: "foo", password: "bar123"))
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .badRequest)
      }
    )
  }

  // GET /auth/me
  func testToken() throws {
    var token: String = ""
    try app.test(
      .POST, "auth/register",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: "foo", password: "bar123"))
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .created)
        let response = try res.content.decode(UserResponse.self)
        token = response.token
      }
    )
    // 200 if using a valid token
    try app.test(
      .GET, "auth/me",
      beforeRequest: { req in
        // Set token of user foo
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(CurrentUser.self)
        XCTAssertEqual(response.username, "foo")
      }
    )

    // 401 if token is not present
    try app.test(
      .GET, "auth/me",
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

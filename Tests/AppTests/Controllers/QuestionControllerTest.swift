import XCTVapor

@testable import App

final class QuestionControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // GET /questions
  func testIndex() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)

    try app.test(
      .GET, "questions",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(PaginatedQuestions.self)
        XCTAssertEqual(response.items[0].body, question.body)
      })
  }

  // GET /questions/search
  func testSearch() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(category: Category.arts, on: app.db, user: user)
    let _ = try newQuestion(on: app.db, user: user)

    try app.test(
      .GET, "questions/search?category=Arts",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(PaginatedQuestions.self)
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items[0].body, question.body)
      })
  }

  // GET /questions/:id
  func testGetOne() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(category: Category.arts, on: app.db, user: user)
    try app.test(
      .GET, "questions/\(question.id!)",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(QuestionResponse.self)
        XCTAssertEqual(response.body, question.body)
      })
  }

  // GET /questions/me
  func testUserQuestions() throws {
    // Verify tests does not get other users questions
    let anotherUser = try newUser(on: app.db)
    let _ = try newQuestion(category: Category.arts, on: app.db, user: anotherUser)
    // Generate token
    let user = try newUser("testUserQuestions", "bar123", on: app.db)
    let question = try newQuestion(category: Category.arts, on: app.db, user: user)
    var token: String = ""
    try app.test(
      .POST, "auth/login",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: user.username, password: "bar123"))
      },
      afterResponse: { res in
        let response = try res.content.decode(UserResponse.self)
        token = response.token
      }
    )
    // 200 if using a valid token
    try app.test(
      .GET, "questions/me",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(PaginatedQuestions.self)
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items[0].body, question.body)
      }
    )
    // 401 if not token present
    try app.test(
      .GET, "questions/me",
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
  }

  // POST /questions
  func testCreate() throws {
    let content = ["body": "What is love?", "category": "General Knowledge"]
    // Generate token
    var token: String = ""
    try app.test(
      .POST, "auth/register",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: "testCreate", password: "bar123"))
      },
      afterResponse: { res in
        let response = try res.content.decode(UserResponse.self)
        token = response.token
      }
    )
    // 200 if using a valid token
    try app.test(
      .POST, "questions",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(QuestionResponse.self)
        XCTAssertEqual(response.body, content["body"])
      }
    )
    // 401 if not token present
    try app.test(
      .POST, "questions",
      beforeRequest: { req in
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

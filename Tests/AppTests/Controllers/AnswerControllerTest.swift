import XCTVapor

@testable import App

final class AnswerControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // GET /questions/:id/answers
  func testIndex() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)
    // Verify index doesn't get answers from other question
    let otherQuestion = try newQuestion(on: app.db, user: user)
    let _ = try newAnswer(on: app.db, user: user, question: otherQuestion)

    try app.test(
      .GET, "questions/\(question.id!)/answers",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(PaginatedAnswers.self)
        XCTAssertEqual(response.items[0].body, answer.body)
        XCTAssertEqual(response.items.count, 1)
      })
  }

  // GET /answers/:id
  func testGetOne() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)

    try app.test(
      .GET, "answers/\(answer.id!)",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(AnswerResponse.self)
        XCTAssertEqual(response.body, answer.body)
      })
  }

  // POST /questions/:id/answers
  func testCreate() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let content = ["body": "I don't know"]
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
      .POST, "questions/\(question.id!)/answers",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .created)
        let response = try res.content.decode(AnswerResponse.self)
        XCTAssertEqual(response.body, content["body"])
      }
    )
    // 401 if token is not present
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

  // PUT /answers/:id
  func testUpdate() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)
    let content = ["body": "I don't know"]
    // Generate token
    var token: String = ""
    try app.test(
      .POST, "auth/login",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: user.username, password: "password"))
      },
      afterResponse: { res in
        let response = try res.content.decode(UserResponse.self)
        token = response.token
      }
    )
    // 200 if using a valid token
    try app.test(
      .PUT, "answers/\(answer.id!)",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(AnswerResponse.self)
        XCTAssertEqual(response.body, content["body"])
      }
    )
    // 401 if token is not present
    try app.test(
      .PUT, "answers/\(question.id!)",
      beforeRequest: { req in
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
    let anotherUser = try newUser("test403", on: app.db)
    let anotherAnswer = try newAnswer(on: app.db, user: anotherUser, question: question)
    // 403 if user is not authorized
    try app.test(
      .PUT, "answers/\(anotherAnswer.id!)",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
        try req.content.encode(content)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .forbidden)
      }
    )
  }

  // DELETE /answers/:id
  func testDelete() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)
    // Generate token
    var token: String = ""
    try app.test(
      .POST, "auth/login",
      beforeRequest: { req in
        try req.content.encode(UserRequest(username: user.username, password: "password"))
      },
      afterResponse: { res in
        let response = try res.content.decode(UserResponse.self)
        token = response.token
      }
    )
    // 204 if using a valid token
    try app.test(
      .DELETE, "answers/\(answer.id!)",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .noContent)
      }
    )
    // 401 if token is not present
    try app.test(
      .DELETE, "answers/\(question.id!)",
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
    let anotherUser = try newUser("test403", on: app.db)
    let anotherAnswer = try newAnswer(on: app.db, user: anotherUser, question: question)
    // 403 if user is not authorized
    try app.test(
      .DELETE, "answers/\(anotherAnswer.id!)",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .forbidden)
      }
    )
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

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

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

import XCTVapor

@testable import App

final class VoteControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // POST /answers/:id/upvote
  func testCreate() throws {
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
    // 200 if using a valid token
    try app.test(
      .POST, "answers/\(answer.id!)/upvotes",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .created)
      }
    )
    // 401 if token is not present
    try app.test(
      .POST, "answers/\(answer.id!)/upvotes",
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
    // if user send request more that once, votes count as 1
    try app.test(
      .POST, "answers/\(answer.id!)/upvotes",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      }
    )
    try app.test(
      .GET, "answers/\(answer.id!)",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode(AnswerResponse.self)
        XCTAssertEqual(response.upvotes, 1)
      })
  }

  // DELETE /answers/:id/upvotes or DELETE /answers/:id/downvotes
  func testDelete() throws {
    let user = try newUser(on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)
    let _ = try newVote(on: app.db, user: user, answer: answer, upvote: true)
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
      .DELETE, "answers/\(answer.id!)/upvotes",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .noContent)
      }
    )
    let _ = try newVote(on: app.db, user: user, answer: answer, upvote: false)
    // 200 if using a valid token
    try app.test(
      .DELETE, "answers/\(answer.id!)/downvotes",
      beforeRequest: { req in
        req.headers.bearerAuthorization = .init(token: token)
      },
      afterResponse: { res in
        XCTAssertEqual(res.status, .noContent)
      }
    )
    // 401 if token is not present
    try app.test(
      .POST, "answers/\(answer.id!)/upvotes",
      afterResponse: { res in
        XCTAssertEqual(res.status, .unauthorized)
      }
    )
  }

  // GET /answers/:id/upvotes or GET /answers/:id/downvotes
  func testIndex() throws {
    let user = try newUser(on: app.db)
    let user2 = try newUser("user2", on: app.db)
    let question = try newQuestion(on: app.db, user: user)
    let answer = try newAnswer(on: app.db, user: user, question: question)
    let _ = try newVote(on: app.db, user: user, answer: answer, upvote: true)
    let _ = try newVote(on: app.db, user: user2, answer: answer, upvote: false)
    try app.test(
      .GET, "answers/\(answer.id!)/upvotes",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode([VoteResponse].self)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response[0].username, user.username)
      })
    try app.test(
      .GET, "answers/\(answer.id!)/downvotes",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let response = try res.content.decode([VoteResponse].self)
        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response[0].username, user2.username)
      })
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

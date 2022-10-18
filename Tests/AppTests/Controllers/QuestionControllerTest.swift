import XCTVapor

@testable import App

final class QuestionControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // GET /questions
  func testIndex() throws {
    let question = try newQuestion(on: app.db)

    try app.test(
      .GET, "questions",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let questions = try res.content.decode(PaginatedQuestions.self)
        XCTAssertEqual(questions.items[0].body, question.body)
      })
  }

  // GET /questions/search
  func testSearch() throws {
    let question = try newQuestion(category: Category.arts, on: app.db)
    let _ = try newQuestion(on: app.db)

    try app.test(
      .GET, "questions/search?category=Arts",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let questions = try res.content.decode(PaginatedQuestions.self)
        XCTAssertEqual(questions.items.count, 1)
        XCTAssertEqual(questions.items[0].body, question.body)
      })
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}

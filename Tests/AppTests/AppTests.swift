import XCTVapor

@testable import App

final class AppTests: XCTestCase {
  func testHealth() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)

    try app.test(
      .GET, "health",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        XCTAssertEqual(res.body.string, "Ok")
      })
  }
}

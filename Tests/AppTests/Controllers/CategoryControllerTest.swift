import XCTVapor

@testable import App

final class CategoryControllerTest: XCTestCase {
  var app: Application!

  override func setUpWithError() throws {
    app = try setUpApp()
  }

  // GET /categories
  func testIndex() throws {
    try app.test(
      .GET, "categories",
      afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let categories = try res.content.decode([CategoryResponse].self)
        XCTAssertEqual(categories.count, 12)
      })
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

}

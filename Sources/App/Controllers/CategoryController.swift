import Vapor

struct CategoryController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let categories = routes.grouped("categories")
    categories.get(use: index)
  }

  // GET /categories
  func index(req: Request) async -> [CategoryResponse] {
    var response: [CategoryResponse] = []
    for category in Category.allCases {
      let categoryResponse = CategoryResponse(name: category.rawValue)
      response.append(categoryResponse)
    }
    return response
  }
}

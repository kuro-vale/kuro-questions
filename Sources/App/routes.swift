import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req async in
    "It works!"
  }

  app.get("health") { req async -> String in
    "Ok"
  }

  try app.register(collection: QuestionController())
}

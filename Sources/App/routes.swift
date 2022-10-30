import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req async in
    req.redirect(to: "index.html")
  }

  app.get("health") { req async -> String in
    "Ok"
  }

  try app.register(collection: CategoryController())

  try app.register(collection: QuestionController())

  try app.register(collection: UserController())

  try app.register(collection: AnswerController())

  try app.register(collection: VoteController())
}

import Fluent

@testable import App

func newQuestion(
  _ body: String = "Lorem Ipsum", _ category: Category = Category.technology, on database: Database
) throws -> Question {
  let question = Question(body, category)
  try question.save(on: database).wait()
  return question
}

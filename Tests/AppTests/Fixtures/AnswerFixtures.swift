import Fluent

@testable import App

func newAnswer(body: String = "Lorem Ipsum", on database: Database, user: User, question: Question)
  throws -> Answer
{
  let answer = Answer(body, question.id!, user.id!)
  try answer.save(on: database).wait()
  return answer
}

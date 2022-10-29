import Fluent

@testable import App

func newVote(on database: Database, user: User, answer: Answer, upvote: Bool)
  throws -> Vote
{
  let vote = Vote(userId: user.id!, answerId: answer.id!, upvote: upvote)
  try vote.save(on: database).wait()
  return vote
}

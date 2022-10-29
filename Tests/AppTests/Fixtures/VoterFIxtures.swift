import Fluent

@testable import App

func newVoter(on database: Database, user: User, answer: Answer, upvote: Bool)
  throws -> Voter
{
  let voter = Voter(userId: user.id!, answerId: answer.id!, upvote: upvote)
  try voter.save(on: database).wait()
  return voter
}

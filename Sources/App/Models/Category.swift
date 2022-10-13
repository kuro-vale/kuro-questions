import Vapor

enum Category: String, Codable, CaseIterable {
  case technology = "Technology"
  case geography = "Geography"
  case food = "Food"
  case literature = "Literature"
  case animals = "Animals"
  case science = "Science"
  case music = "Music"
  case generalKnowledge = "General Knowledge"
  case history = "History"
  case arts = "Arts"
  case sports = "Sports"
  case entertainment = "Entertainment"
}

struct CategoryResponse: Content {
  var name: String

  init(name: String) {
    self.name = name
  }
}

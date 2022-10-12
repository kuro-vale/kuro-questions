enum Category: String, Codable {
  case technology, geography, food, literature, animals, science, music, generalKnowledge, history,
    arts, sports, entertainment

  func simpleDescription() -> String {
    switch self {
    case .technology:
      return "Technology"
    case .geography:
      return "Geography"
    case .food:
      return "Food"
    case .literature:
      return "Literature"
    case .animals:
      return "Animals"
    case .science:
      return "Science"
    case .music:
      return "Music"
    case .generalKnowledge:
      return "General Knowledge"
    case .history:
      return "History"
    case .arts:
      return "Arts"
    case .sports:
      return "Sports"
    case .entertainment:
      return "Entertainment"
    }
  }
}

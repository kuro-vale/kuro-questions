import Fluent
import Vapor

struct ServerMetadata: Content {
  var first: String
  var last: String
  var previous: String?
  var next: String?
  var current: String
  var total: Int
  var per: Int
}

func serverMetadataAssembler(_ metadata: PageMetadata, path: String, query: String = "")
  -> ServerMetadata
{
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"
  var ampersand = ""
  if query != "" {
    ampersand = "&"
  }

  // Example url host/questions/search?page=1&q=example
  let lastPage = Int(ceil(Double(metadata.total) / Double(metadata.per)))
  let first = "\(host)\(path)?page=1\(ampersand)\(query)"
  let last = "\(host)\(path)?page=\(lastPage)\(ampersand)\(query)"
  let current = "\(host)\(path)?page=\(metadata.page)\(ampersand)\(query)"
  var previous: String? = "\(host)\(path)?page=\(metadata.page - 1)\(ampersand)\(query)"
  var next: String? = "\(host)\(path)?page=\(metadata.page + 1)\(ampersand)\(query)"

  if metadata.page <= 1 {
    previous = nil
  }
  if metadata.page >= lastPage {
    next = nil
  }

  return ServerMetadata(
    first: first, last: last, previous: previous, next: next, current: current,
    total: metadata.total, per: metadata.per)
}

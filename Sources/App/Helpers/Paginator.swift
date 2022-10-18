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

func ServerMetadataAssembler(_ metadata: PageMetadata, path: String, query: String = "")
  -> ServerMetadata
{
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"

  // Example url host/questions/search?page=1&q=example
  let last_page = Int(ceil(Double(metadata.total) / Double(metadata.per)))
  let first = "\(host)\(path)?page=1\(query)"
  let last = "\(host)\(path)?page=\(last_page)\(query)"
  let current = "\(host)\(path)?page=\(metadata.page)\(query)"
  var previous: String? = "\(host)\(path)?page=\(metadata.page - 1)\(query)"
  var next: String? = "\(host)\(path)?page=\(metadata.page + 1)\(query)"

  if metadata.page <= 1 {
    previous = nil
  }
  if metadata.page >= last_page {
    next = nil
  }

  return ServerMetadata(
    first: first, last: last, previous: previous, next: next, current: current,
    total: metadata.total, per: metadata.per)
}

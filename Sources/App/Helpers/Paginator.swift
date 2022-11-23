import Fluent
import Vapor

/// Custom HATEOAS metadata
struct ServerMetadata: Content {
  var first: String
  var last: String
  var previous: String?
  var next: String?
  var current: String
  var total: Int
  var per: Int
}

/// Generate a `ServerMetadata` model
func serverMetadataAssembler(_ metadata: PageMetadata, reqUrl: URI)
  -> ServerMetadata
{
  let host = Environment.get("APP_HOSTNAME") ?? "127.0.0.1"
  var url = reqUrl.string
  if !url.contains("page=") {
    url += ((url.contains("?")) ? "&" : "?") + "page=1"
  }
  let regex = try! NSRegularExpression(pattern: "(page=)\\d")
  let range = NSMakeRange(0, url.count)
  // Example url host/questions/search?page=1&q=example
  let lastPage = Int(ceil(Double(metadata.total) / Double(metadata.per)))
  let first = "\(host)\(regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "$11"))"
  let last = "\(host)\(regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "$1\(lastPage)"))"
  let current = "\(host)\(regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "$1\(metadata.page)"))"
  var previous: String? = "\(host)\(regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "$1\(metadata.page - 1)"))"
  var next: String? = "\(host)\(regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "$1\(metadata.page + 1)"))"

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

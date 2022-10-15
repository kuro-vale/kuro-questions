import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  let database_name: String

  if app.environment == .testing {
    database_name = "vapor_test"
  } else {
    database_name = Environment.get("DATABASE_NAME") ?? "vapor_database"
  }

  app.databases.use(
    .postgres(
      hostname: Environment.get("DATABASE_HOST") ?? "localhost",
      port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
        ?? PostgresConfiguration.ianaPortNumber,
      username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
      password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
      database: database_name
    ), as: .psql)

  app.migrations.add(CreateQuestion())

  // register routes
  try routes(app)
}

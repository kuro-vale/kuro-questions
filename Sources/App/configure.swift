import Fluent
import FluentPostgresDriver
import JWT
import Vapor

// configures your application
public func configure(_ app: Application) throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "vapor_secret"))

  let databaseName: String

  if app.environment == .testing {
    databaseName = Environment.get("TEST_DATABASE_NAME") ?? "vapor_test"
  } else {
    databaseName = Environment.get("DATABASE_NAME") ?? "vapor_database"
  }

  app.databases.use(
    .postgres(
      hostname: Environment.get("DATABASE_HOST") ?? "localhost",
      port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
        ?? PostgresConfiguration.ianaPortNumber,
      username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
      password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
      database: databaseName
    ), as: .psql)

  app.migrations.add(CreateUser())
  app.migrations.add(CreateQuestion())

  // Run migrations
  try app.autoMigrate().wait()

  // register routes
  try routes(app)
}

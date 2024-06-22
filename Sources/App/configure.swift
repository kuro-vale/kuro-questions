import Fluent
import FluentPostgresDriver
import JWT
import Vapor

// configures your application
public func configure(_ app: Application) throws {
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  let corsConfiguration = CORSMiddleware.Configuration(
      allowedOrigin: .all,
      allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
      allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  app.middleware.use(cors, at: .beginning)

  // Set JWT sign secret
  app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "vapor_secret"))

  // Configure Database
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

  // Register migrations
  app.migrations.add(CreateUser())
  app.migrations.add(CreateQuestion())
  app.migrations.add(CreateAnswer())

  // Run migrations
  try app.autoMigrate().wait()

  // Register routes
  try routes(app)
}

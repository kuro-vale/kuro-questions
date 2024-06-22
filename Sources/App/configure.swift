import Fluent
import FluentSQLiteDriver
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

  app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

  // Register migrations
  app.migrations.add(CreateUser())
  app.migrations.add(CreateQuestion())
  app.migrations.add(CreateAnswer())

  // Run migrations
  try app.autoMigrate().wait()

  // Register routes
  try routes(app)
}

import App
import XCTVapor

func setUpApp() throws -> Application {
  let app = Application(.testing)
  try configure(app)

  try app.autoRevert().wait()
  try app.autoMigrate().wait()

  return app
}

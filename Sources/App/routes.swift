import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymsController = AcronymController()
    try app.register(collection: acronymsController)
    
    let userController = UserController()
    try app.register(collection: userController)
    
    let categoryController = CategoryController()
    try app.register(collection: categoryController)
    
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
}

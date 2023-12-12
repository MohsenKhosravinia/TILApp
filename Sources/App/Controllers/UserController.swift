import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users")
        userRoutes.post(use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.get(":userID", use: getHandler)
    }
    
    private func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    private func  getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    private func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}


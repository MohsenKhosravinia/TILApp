import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "category")
        userRoutes.post(use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.get(":categoryID", use: getHandler)
    }
    
    private func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        category.id = UUID()
        return category.save(on: req.db).map { category }
    }
    
    private func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    private func getHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}

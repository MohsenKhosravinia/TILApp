import Vapor
import Fluent

struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoutes = routes.grouped("api", "categories")
        categoriesRoutes.post(use: createHandler)
        categoriesRoutes.get(use: getAllHandler)
        categoriesRoutes.get(":categoryID", use: getHandler)
        categoriesRoutes.get(":categoryID", "acronyms", use: getAcronymsHandler)
        categoriesRoutes.delete(":categoryID", use: deleteCategoryHandler)
    }
    
    private func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        
        return Category.query(on: req.db)
            .filter(\.$name == category.name)
            .first()
            .flatMap { existingCategory in
                if let existingCategory {
                    return req.eventLoop.makeSucceededFuture(existingCategory)
                } else {
                    category.name = category.name.lowercased()
                    category.id = UUID()
                    return category.save(on: req.db).map { category }
                }
            }
    }
    
    private func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    private func getHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    private func getAcronymsHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.$acronyms.get(on: req.db)
            }
    }
    
    private func deleteCategoryHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.delete(on: req.db).transform(to: .noContent)
            }
    }
}

import Vapor
import Fluent

struct AcronymController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        acronymsRoutes.get("search", use: searchHandler)
    }
    
    private func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym
            .query(on: req.db)
            .all()
    }
    
    private func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: req.db).map { acronym }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let id: UUID? = req.parameters.get("acronymID")
        
        return Acronym
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
        
    }
    
    private func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id: UUID? = req.parameters.get("acronymID")
        
        return Acronym
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db).transform(to: .noContent)
            }
    }
    
    private func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    
    private func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
    
    private func getCategoriesHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories.get(on: req.db)
            }
    }
    
    private func addCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let categoryQuery = Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery).flatMap { acronym, category in
            acronym.$categories.attach(category, on: req.db).transform(to: .created)
        }
    }
    
    private func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
    }
}

/// DTO (Domain Transfer Object)
struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}

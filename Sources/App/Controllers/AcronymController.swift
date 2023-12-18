import Vapor

class AcronymController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
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
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id: UUID? = req.parameters.get("acronymID")
        
        return Acronym
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db).transform(to: .noContent)
            }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
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
    
    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
}

/// DTO (Domain Transfer Object)
struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}

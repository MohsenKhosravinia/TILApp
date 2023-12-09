import Fluent
import Vapor

final class Todo: Model, Content {
    static let schema = "acronyms"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String

    init() {}

    init(id: UUID?, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

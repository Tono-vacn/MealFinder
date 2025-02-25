import Fluent
import Vapor

final class UserToken: Model, Content, @unchecked Sendable {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var token: String

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil, token: String, userID: UUID) {
        self.id = id
        self.token = token
        self.$user.id = userID
    }
}

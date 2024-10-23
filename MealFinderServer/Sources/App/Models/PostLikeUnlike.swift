import Vapor
import Fluent

final class PostUserLike: Model, @unchecked Sendable {
    static let schema = "post_user_likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User
}

final class PostUserDislike: Model, @unchecked Sendable {
    static let schema = "post_user_dislikes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User
}
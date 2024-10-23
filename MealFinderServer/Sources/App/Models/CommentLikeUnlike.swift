import Vapor
import Fluent

final class CommentUserLike: Model, @unchecked Sendable {
    static let schema = "comment_user_likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "comment_id")
    var comment: Comment

    @Parent(key: "user_id")
    var user: User
}

final class CommentUserDislike: Model, @unchecked Sendable {
    static let schema = "comment_user_dislikes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "comment_id")
    var comment: Comment

    @Parent(key: "user_id")
    var user: User
}
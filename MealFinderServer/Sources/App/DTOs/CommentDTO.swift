import Vapor
import Fluent

struct CommentDTO: Content {
    var id: UUID?
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var postId: UUID?
    var parentCommentId: UUID?
    var userId: UUID?

    func toModel() -> Comment {
        return Comment(
            id: self.id,
            title: self.title,
            content: self.content,
            likes: self.likes,
            dislikes: self.dislikes,
            post_id: self.postId,
            parentComment_id: self.parentCommentId,
            user_id: self.userId
        )
    }
}
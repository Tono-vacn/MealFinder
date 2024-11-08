import Vapor
import Fluent

enum CreateCommentStatus: String, Content {
    case success = "success"
    case fail = "fail"
}

struct CommentDTO: Content {
    var id: UUID?
    var title: String
    var content: String
    var likes: Int
    var dislikes: Int
    var postId: UUID?
    var parentCommentId: UUID?
    var userId: UUID?
    var haveComments: Bool

    // func toModel() -> Comment {
    //     return Comment(
    //         id: self.id,
    //         title: self.title,
    //         content: self.content,
    //         likes: self.likesCount,
    //         dislikes: self.dislikesCount,
    //         post_id: self.postId,
    //         parentComment_id: self.parentCommentId,
    //         user_id: self.userId
    //     )
    // }
}

struct CreateCommentRequest: Content {
    var title: String
    var content: String
}

struct CreateCommentResponse: Content {
    var status: CreateCommentStatus
    var comment: CommentDTO?
}

struct FetchCommentsRequest: Content {
    var commentID: UUID
}
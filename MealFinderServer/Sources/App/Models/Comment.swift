import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Comment: Model, @unchecked Sendable {
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "content")
    var content: String

    // @Field(key: "likes")
    // var likes: Int

    // @Field(key: "dislikes")
    // var dislikes: Int

    @Siblings(through: CommentUserLike.self, from: \.$comment, to: \.$user)
    var likes: [User]

    @Siblings(through: CommentUserDislike.self, from: \.$comment, to: \.$user)
    var dislikes: [User]

    @Parent(key: "post_id")
    var post: Post

    // 可选的父评论（建立自引用关系）
    @OptionalParent(key: "parent_comment_id")
    var parentComment: Comment?

    // 子评论的集合
    @Children(for: \.$parentComment)
    var replies: [Comment]

    // 可选的用户关联
    @OptionalParent(key: "user_id")
    var user: User?

    init() { }

    init(id: UUID? = nil, title: String, content: String, post_id: UUID? = nil, parentComment_id: UUID? = nil, user_id: UUID? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.likes = []
        self.dislikes = []
        if let post_id = post_id {
            self.$post.id = post_id
        }
        if let parentComment_id = parentComment_id {
            self.$parentComment.id = parentComment_id
        }
        if let user_id = user_id {
            self.$user.id = user_id
        }
    }

    func toDTO() -> CommentDTO {
        return CommentDTO(
            id: self.id,
            title: self.title,
            content: self.content,
            likes: self.likes.count,
            dislikes: self.dislikes.count,
            postId: self.$post.id,
            parentCommentId: self.$parentComment.id,
            userId: self.$user.id
        )
    }
    
}

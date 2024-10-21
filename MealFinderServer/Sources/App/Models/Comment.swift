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

    @Field(key: "likes")
    var likes: Int

    @Field(key: "dislikes")
    var dislikes: Int

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

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }

    // func toDTO() -> CommentDTO {
    //     return CommentDTO(id: self.id, title: self.title, content: self.content, likes: self.likes, dislikes: self.dislikes, parentComment: self.parentComment, childrenComments: self.childrenComments, user: self.user)
    // }
    
}

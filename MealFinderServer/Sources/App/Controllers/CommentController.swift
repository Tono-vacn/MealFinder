import Fluent
import Vapor

struct CommentController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let comments = routes.grouped("comments")
    comments.group(":commentID") { comment in
      comment.get(use: fetchMoreComments)
    }
    // comments.post(use: fetchMoreComments)
    let tokenProtected = comments.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtected.group(":commentID") { comment in
      comment.post(use: createComment)
      comment.delete(use: deleteComment)
      comment.post("like", use: likeComment)
      comment.post("dislike", use: dislikeComment)
    }

  }

  @Sendable
  func fetchMoreComments(req: Request) async throws -> [CommentDTO] {
    // let param = try req.content.decode(FetchCommentsRequest.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let children = try await comment.$replies.query(on: req.db).all()
    // return children.map { $0.toDTO() }
    return try await children.async.reduce(into: []) { (result, comment) in
      result.append(try await comment.toDTO(on: req.db))
    }
  }

  @Sendable
  func createComment(req: Request) async throws -> CreateCommentResponse {
    let curUser = try req.auth.require(User.self)
    guard let curComment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
        throw Abort(.notFound)
    }
    let rawComment = try req.content.decode(CreateCommentRequest.self)
    let comment = Comment(title: rawComment.title, content: rawComment.content, parentComment_id: curComment.id, user_id: curUser.id)
    try await comment.save(on: req.db)
    return CreateCommentResponse(status: .success, comment: try await comment.toDTO(on: req.db))
  }

  @Sendable
  func deleteComment(req: Request) async throws -> HTTPStatus {
    let curUser = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
        throw Abort(.notFound)
    }
    guard comment.$user.id == curUser.id else {
        throw Abort(.forbidden)
    }
    try await comment.delete(on: req.db)
    return .noContent
  }

  @Sendable
  func likeComment(req: Request) async throws -> CommentDTO {
    let curUser = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
        throw Abort(.notFound)
    }

    if let existingLike = try await CommentUserLike.query(on: req.db).filter(\.$comment.$id == comment.id!).filter(\.$user.$id == curUser.id!).first() {
      try await req.db.transaction { db in 
        try await existingLike.delete(on: db)
        comment.likesCount = comment.likesCount - 1
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    }else if let existingDislike = try await CommentUserDislike.query(on: req.db).filter(\.$comment.$id == comment.id!).filter(\.$user.$id == curUser.id!).first() {
      let like = CommentUserLike(comment_id: comment.id!, user_id: curUser.id!)
      try await req.db.transaction { db in
        try await existingDislike.delete(on: db)
        comment.dislikesCount = comment.dislikesCount - 1
        comment.likesCount = comment.likesCount + 1
        try await like.save(on: db)
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    }
    else{
      let like = CommentUserLike(comment_id: comment.id!, user_id: curUser.id!)
      try await req.db.transaction { db in
        try await like.save(on: db)
        comment.likesCount = comment.likesCount + 1
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    } 
  }

  @Sendable
  func dislikeComment(req: Request) async throws -> CommentDTO {
    let curUser = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
        throw Abort(.notFound)
    }

    if let existingDislike = try await CommentUserDislike.query(on: req.db).filter(\.$comment.$id == comment.id!).filter(\.$user.$id == curUser.id!).first() {
      try await req.db.transaction { db in
        try await existingDislike.delete(on: db)
        comment.dislikesCount = comment.dislikesCount - 1
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    }else if let existingLike = try await CommentUserLike.query(on: req.db).filter(\.$comment.$id == comment.id!).filter(\.$user.$id == curUser.id!).first() {
      let dislike = CommentUserDislike(comment_id: comment.id!, user_id: curUser.id!)
      try await req.db.transaction { db in
        try await existingLike.delete(on: db)
        comment.likesCount = comment.likesCount - 1
        comment.dislikesCount = comment.dislikesCount + 1
        try await dislike.save(on: db)
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    }    
    else{
      let dislike = CommentUserDislike(comment_id: comment.id!, user_id: curUser.id!)
      try await req.db.transaction { db in
        try await dislike.save(on: db)
        comment.dislikesCount = comment.dislikesCount + 1
        try await comment.save(on: db)
      }
      return try await comment.toDTO(on: req.db)
    } 
  }

}
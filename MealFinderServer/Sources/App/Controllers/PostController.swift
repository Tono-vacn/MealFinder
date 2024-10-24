import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: index)
        posts.post(use: indexByOrderWithQuantity)
        // recipes.post(use: create)
        posts.group(":postID") { post in
            // recipe.delete(use: delete)
            post.get(use: QueryByID)
            post.get("comments", use: QueryCommentsByPostID)
            // post.post("like", use: likePost)
            // post.post("dislike", use: dislikePost)
            
        }

        let tokenProtected = posts.grouped(UserToken.authenticator(), User.guardMiddleware())
        tokenProtected.post(use: create)
        tokenProtected.group(":postID") { post in
            // recipe.delete(use: delete)
            post.delete(use: delete)
            post.post("like", use: likePost)
            post.post("dislike", use: dislikePost)
            post.put(use: update)
            post.post("comments", use: CommentPost)
        }
        

    }

    @Sendable
    func index(req: Request) async throws -> [PostDTO] {
        try await Post.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func indexByOrderWithQuantity(req: Request) async throws -> [PostDTO] {
        let param = try req.content.decode(IndexByOrderWithQuantityRequest.self)
        switch param.order {
          case .createdAt:
            let posts = try await Post.query(on: req.db).sort(\.$createdAt, param.direction == .desc ? .descending : .ascending).range(lower: param.index ?? 0, upper: (param.index ?? 0) + (param.offset ?? 10)).all()
            return posts.map { $0.toDTO() }
          case .updatedAt:
            let posts = try await Post.query(on: req.db).sort(\.$updatedAt, param.direction == .desc ? .descending : .ascending).range(lower: param.index ?? 0, upper: (param.index ?? 0) + (param.offset ?? 10)).all()
            return posts.map { $0.toDTO() }
          case .likes:
            let posts = try await Post.query(on: req.db).sort(\.$likesCount, param.direction == .desc ? .descending : .ascending).range(lower: param.index ?? 0, upper: (param.index ?? 0) + (param.offset ?? 10)).all()
            return posts.map { $0.toDTO() }
          default:
            return []
        }
        // let posts = try await Post.query(on: req.db).sort().range(lower: param.index ?? 0, upper: param.index ?? 0 + param.offset ?? 10).all()
        // return posts.map { $0.toDTO() }
    }
        

    @Sendable
    func QueryByID(req: Request) async throws -> PostDTO {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return post.toDTO()
    } 

    @Sendable
    func QueryCommentsByPostID(req: Request) async throws -> [CommentDTO] {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await post.$comments.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        let rawPost = try req.content.decode(CreatePostRequest.self)
        try await req.db.transaction { db in
          let recipe = Recipe(title: rawPost.recipe.title, content: rawPost.recipe.content, ingredients: rawPost.recipe.ingredients)
          try await recipe.save(on: db)
          let post = Post(title: rawPost.title, content: rawPost.content, createdAt: Date(), updatedAt: Date(), userId: curUser.id, recipeId: recipe.id)
          try await post.save(on: db)
        }
        return .created
    }

    @Sendable 
    func update(req: Request) async throws -> HTTPStatus {
      let curUser = try req.auth.require(User.self)
      guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let rawPost = try req.content.decode(UpdatePostRequest.self)
      guard post.$user.id == curUser.id else {
        throw Abort(.forbidden)
      }
      if let title = rawPost.title {
        post.title = title
      }
      if let content = rawPost.content {
        post.content = content
      }
      try await post.save(on: req.db)
      return .noContent
    } 

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
      let curUser = try req.auth.require(User.self)
      guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
          throw Abort(.notFound)
      }
      guard post.$user.id == curUser.id else {
        throw Abort(.forbidden)
      }
      try await post.delete(on: req.db)
      return .noContent
    }

    @Sendable
    func likePost(req: Request) async throws -> PostDTO {
      let curUser = try req.auth.require(User.self)
      guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
          throw Abort(.notFound)
      }
      // guard post.$user.id == curUser.id else {
      //   throw Abort(.forbidden)
      // }

      if let existingLike = try await PostUserLike.query(on: req.db).filter(\.$post.$id == post.id!).filter(\.$user.$id == curUser.id!).first() {
        try await req.db.transaction { db in 
          try await existingLike.delete(on: db)
          post.likesCount = post.likesCount - 1
          try await post.save(on: db)
        }
        return post.toDTO()
      }else{
        let like = PostUserLike(post_id: post.id!, user_id: curUser.id!)
        try await req.db.transaction { db in
          try await like.save(on: db)
          post.likesCount = post.likesCount + 1
          try await post.save(on: db)
        }
        return post.toDTO()
      } 

      // let like = PostUserLike(postId: post.id!, userId: curUser.id!)
      // try await like.save(on: req.db)
      // return .created
    }

    @Sendable
    func dislikePost(req: Request) async throws -> PostDTO {
      let curUser = try req.auth.require(User.self)
      guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
          throw Abort(.notFound)
      }

      if let existingDislike = try await PostUserDislike.query(on: req.db).filter(\.$post.$id == post.id!).filter(\.$user.$id == curUser.id!).first() {
        try await req.db.transaction { db in
          try await existingDislike.delete(on: db)
          post.dislikesCount = post.dislikesCount - 1
          try await post.save(on: db)
        }
        return post.toDTO()
      }else{
        let dislike = PostUserDislike(post_id: post.id!, user_id: curUser.id!)
        try await req.db.transaction { db in
          try await dislike.save(on: db)
          post.dislikesCount = post.dislikesCount + 1
          try await post.save(on: db)
        }
        return post.toDTO()
      } 
    }

    @Sendable
    func CommentPost(req: Request) async throws -> HTTPStatus {
      let curUser = try req.auth.require(User.self)
      guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let rawComment = try req.content.decode(CreateCommentRequest.self)
      let comment = Comment(title: rawComment.title, content: rawComment.content, post_id: post.id!, user_id: curUser.id)
      try await comment.save(on: req.db)
      return .created
    }
}
import Fluent
import Vapor

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let users = routes.grouped("users")

    users.post(use: create)
    users.get(use: index)
    users.group(":userID") { user in 
      user.get(use: QueryByID)
      // user.put(use: update)
      // user.delete(use: delete)
    }

    let tokenProtected = users.grouped(UserToken.authenticator())
    tokenProtected.get("me", use: me)
    tokenProtected.post("logout", use: logout)
    tokenProtected.group(":userID") { user in
      user.put(use: update)
      user.delete(use: delete)
    }
    // tokenProtected.put("update", use: update)
    // tokenProtected.delete("delete", use: delete)
    users.post("login", use: login)

  }

  @Sendable
  func index(req: Request) async throws -> [UserDTO] {
    try await User.query(on: req.db).all().map { $0.toDTO() }
  }

  @Sendable
  func create(req: Request) async throws -> UserDTO {
    let rawUser = try req.content.decode(CreateUserRequest.self)

    let user = try await User.query(on: req.db).group(.or){
      or in 
      or.filter(\.$username == rawUser.username)
      or.filter(\.$email == rawUser.email)
    }.first()

    guard user == nil else {
      throw Abort(.badRequest, reason: "User already exists")
    }

    do {
      let user = User(username: rawUser.username, email: rawUser.email, passwordHash: try Bcrypt.hash(rawUser.password))
      try await user.save(on: req.db)
      return user.toDTO()
    }catch {
      throw Abort(.badRequest, reason: "Failed to create user")
    }
  }

  @Sendable
  func delete(req: Request) async throws -> HTTPStatus {
    let curUser = try req.auth.require(User.self)
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }

    guard curUser.id == user.id else {
      throw Abort(.forbidden)
    }

    try await user.delete(on: req.db)
    return .noContent
  }

  @Sendable
  func QueryByID(req: Request) async throws -> UserDTO {
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }

    return user.toDTO()
  }

  @Sendable
  func update(req: Request) async throws -> UserDTO {
    let curUser = try req.auth.require(User.self)
    let rawUser = try req.content.decode(UpdateUserRequest.self)
    
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      // print(req.parameters.get("userID"))
      throw Abort(.notFound)
    }

    guard curUser.id == user.id else {
      throw Abort(.forbidden)
    }

    user.username = rawUser.username ?? user.username
    user.email = rawUser.email ?? user.email
    if let password = rawUser.password {
      do {
        user.passwordHash = try Bcrypt.hash(password)
      } catch {
        throw Abort(.internalServerError, reason: "Failed to hash password")
      }
    }

    try await user.save(on: req.db)
    return user.toDTO()
  }

  @Sendable
  func QueryByEmail(req: Request) async throws -> UserDTO {
    guard let emailValue = req.parameters.get("email") else {
      throw Abort(.badRequest)
    }

    guard let user = try await User.query(on: req.db).filter(\.$email == emailValue).first() else {
      throw Abort(.notFound)
    }

    return user.toDTO()
  }

  @Sendable
  func QueryByName(req: Request) async throws -> UserDTO {
    guard let usernameValue = req.parameters.get("username") else {
      throw Abort(.badRequest)
    }

    guard let user = try await User.query(on: req.db).filter(\.$username == usernameValue).first() else {
      throw Abort(.notFound)
    }

    return user.toDTO()
  }

  @Sendable
  func login(req: Request) async throws -> TokenDTO {
    let loginRequest = try req.content.decode(LoginRequest.self)

    guard let user = try await User.query(on: req.db).filter(\.$username == loginRequest.username).first() else {
      throw Abort(.unauthorized)
    }

    do {
      if try user.verify(password: loginRequest.password) {
        let tokenString = [UInt8].random(count: 16).base64
        let token = UserToken(token: tokenString, userID: try user.requireID())
        try await token.save(on: req.db)
        return TokenDTO(token: tokenString)
      } else {
        throw Abort(.unauthorized, reason: "Invalid credentials")
      }
    } catch {
      throw Abort(.unauthorized, reason: "Invalid credentials")
    }
  }

  @Sendable
  func logout(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let token = try await UserToken.query(on: req.db).filter(\.$user.$id == user.requireID()).first() else {
      throw Abort(.unauthorized)
    }

    try await token.delete(on: req.db)
    return .ok
  }

  @Sendable
  func me(req: Request) async throws -> UserDTO {
    let user = try req.auth.require(User.self)
    return user.toDTO()
  }

}
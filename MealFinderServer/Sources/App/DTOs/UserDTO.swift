import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var username: String?
    var email: String?
    // var passwordHash: String?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let username = self.username {
            model.username = username
        }
        if let email = self.email {
            model.email = email
        }
        // if let passwordHash = self.passwordHash {
        //     model.passwordHash = passwordHash
        // }
        return model
    }
}

struct RawUserDTO: Content {
    var username: String
    var email: String
    var password: String
}

struct CreateUserRequest: Content {
    var username: String
    var email: String
    var password: String
}

struct UpdateUserRequest: Content {
    // var userID: UUID?
    var username: String?
    var email: String?
    var password: String?
}

struct LoginRequest: Content {
    var username: String
    var password: String
}

struct TokenDTO: Content {
    var token: String
}

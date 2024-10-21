import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var username: String?
    var email: String?
    var passwordHash: String?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let username = self.username {
            model.username = username
        }
        if let email = self.email {
            model.email = email
        }
        if let passwordHash = self.passwordHash {
            model.passwordHash = passwordHash
        }
        return model
    }
}
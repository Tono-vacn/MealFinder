import Vapor
import Fluent

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$token
    static let userKey = \UserToken.$user

    typealias User = App.User

    var isValid: Bool {
        true  // 可根据需要添加令牌过期逻辑
    }
}

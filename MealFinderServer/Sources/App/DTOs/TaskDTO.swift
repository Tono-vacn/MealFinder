import Vapor
import Fluent
import Redis

enum TaskStatus: String, Content {
    case pending
    case completed
    case failed
    case error
}

// struct TaskDTO: Content, RESPValueConvertible {
struct TaskDTO: Content {
    var taskID: UUID
    var key: String
    var url: String 

    // init?(fromRESP resp: RESPValue) {
    //     guard case .array(let values) = resp,
    //           values.count == 3,
    //           let taskID =  values[0].string.flatMap(UUID.init(uuidString:)),
    //           let key = values[1].string.flatMap(UUID.init(uuidString:)), 
    //           let url = values[2].string
    //           else {
    //         return nil
    //     }
    //     self.taskID = taskID
    //     self.key = key
    //     self.url = url
    // }

    init(taskID: UUID, key: String, url: String) {
        self.taskID = taskID
        self.key = key
        self.url = url
    }
    
    // func convertedToRESPValue() -> RESPValue {
    //     .array([
    //         .bulkString(ByteBuffer(string: taskID.uuidString)),
    //         .bulkString(ByteBuffer(string: key.uuidString)),
    //         .bulkString(ByteBuffer(string: url))
    //     ])
    // }

    func toString() throws -> String? {
        // "\(taskID.uuidString) \(key.uuidString) \(url)"
        let jsonData = try JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)
    }
}

// submit a picture to create a task
struct CreateTaskRequest: Content {
    var image: File
}

struct CheckTaskRequest: Content {
    var taskID: UUID
}

struct CheckTaskResponse: Content {
    var taskID: UUID
    var status: TaskStatus
    var result: [String]? // the result of the task
}
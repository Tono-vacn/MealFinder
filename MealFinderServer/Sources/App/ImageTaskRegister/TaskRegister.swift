import Fluent
import SotoS3
import Vapor
import Redis
import RabbitMq

struct TaskRegister: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let tasks = routes.grouped("tasks")
    let tokenProtected = tasks.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtected.group(":taskID") { task in
      task.get(use: checkTask)
    }
    tokenProtected.post(use: createTask)
  }

  @Sendable
  func createTask(req: Request) async throws -> TaskDTO {
    /*
    By creating a task, the server will
    1. save the image to the S3 bucket
    2. create a task in the message queue
    3. return the taskID
    */
    let createTaskRequest = try req.content.decode(CreateTaskRequest.self)
    let imageData = createTaskRequest.image.data
    let s3 = req.aws.s3
    let bucket = AppConfig.shared.s3Bucket
    let key = UUID()
    let uploadRequest = S3.PutObjectRequest(
      acl: .publicRead,
      body: AWSPayload.byteBuffer(imageData),
      bucket: bucket,
      key: key.uuidString
    )
    let res = try await s3.putObject(uploadRequest)
    let task = TaskDTO(taskID: UUID(), key: key, url: "http://\(bucket).s3.amazonaws.com/\(key.uuidString)")
    // let channelName: RedisChannelName = "\(AppConfig.shared.redisChannel)"

    // _ = try await req.redis.publish(task, to: channelName).get()
    guard let taskString = try task.toString() else {
      throw Abort(.internalServerError)
    }
    try await req.rabbitMQ.publisher.publish(taskString, routingKey: "task")

    return task
  }

  @Sendable
  func checkTask(req: Request) async throws -> CheckTaskResponse {
    /*
    this function will check the result in redis to see if the task is completed
    */

    // let checkTaskRequest = try req.content.decode(CheckTaskRequest.self)  
    // let taskID = checkTaskRequest.taskID
    guard let taskID = req.parameters.get("taskID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    let taskVal = try await req.redis.get("\(taskID.uuidString)").get()

    switch taskVal {
      case .null:
        return CheckTaskResponse(taskID: taskID, status: .pending, result: nil)
      case .simpleString(let result):
        let resultString = result.getString(at: result.readerIndex, length: result.readableBytes) ?? ""
        return CheckTaskResponse(taskID: taskID, status: .completed, result: [resultString])
      case .array(let result):
        let resArray = result.map { res in 
          guard case .simpleString(let strVal) = res else {
            return ""
          }
          return strVal.getString(at: strVal.readerIndex, length: strVal.readableBytes) ?? ""
        }
        return CheckTaskResponse(taskID: taskID, status: .completed, result: resArray)
      default:
        return CheckTaskResponse(taskID: taskID, status: .pending, result: nil)
    }
  }

}

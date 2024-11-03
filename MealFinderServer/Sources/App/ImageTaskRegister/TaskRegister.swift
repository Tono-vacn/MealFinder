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
      // task.get(use: checkTask)
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

    try await req.rabbitMQ.publisher.publish(task.toString())

    return task
  }

  // @Sendable
  // func checkTask(req: Request) async throws -> CheckTaskResponse {

  // }

}

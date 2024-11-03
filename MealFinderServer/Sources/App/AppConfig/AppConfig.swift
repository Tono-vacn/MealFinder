import Foundation
import Vapor

struct AppConfig {
    static let shared = AppConfig()

    static let postgresDefaultPort: Int = 5432
    static let redisDefaultPort: Int = 6379
    static let rabbitMQDefaultPort: Int = 5672

    let redisHostName: String
    let redisPort: Int
    let redisPassword: String
    let redisChannel: String
    
    let postgresHostName: String
    let postgresPort: Int
    let postgresUsername: String
    let postgresPassword: String
    let postgresDatabase: String

    let awsAccessKeyID: String
    let awsSecretAccessKey: String
    let s3Bucket: String

    let rabbitMQHostName: String
    let rabbitMQPort: Int
    let rabbitMQUser: String
    let rabbitMQPassword: String
    var rabbitMQUrl: String {
        "amqp://\(rabbitMQUser):\(rabbitMQPassword)@\(rabbitMQHostName):\(rabbitMQPort)/%2f"
    }



    private init() {
        redisHostName = Environment.get("REDIS_HOST") ?? "localhost"
        redisPort = Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? AppConfig.redisDefaultPort
        redisPassword = Environment.get("REDIS_PASSWORD") ?? ""
        redisChannel = Environment.get("REDIS_CHANNEL") ?? "MealFinderChannel"

        postgresHostName = Environment.get("DATABASE_HOST") ?? "localhost"
        postgresPort = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? AppConfig.postgresDefaultPort
        postgresUsername = Environment.get("DATABASE_USERNAME") ?? "vapor_username"
        postgresPassword = Environment.get("DATABASE_PASSWORD") ?? "vapor_password"
        postgresDatabase = Environment.get("DATABASE_NAME") ?? "vapor_database"
      

        s3Bucket = Environment.get("AWS_S3_BUCKET") ?? "MealFinderBucket"
        awsAccessKeyID = Environment.get("AWS_ACCESS_KEY_ID") ?? "YOUR_AWS_ACCESS_KEY_ID"
        awsSecretAccessKey = Environment.get("AWS_SECRET_ACCESS_KEY") ?? "YOUR_AWS_SECRET_ACCESS_KEY"

        rabbitMQHostName = Environment.get("RABBITMQ_HOST") ?? "localhost"
        rabbitMQPort = Environment.get("RABBITMQ_PORT").flatMap(Int.init(_:)) ?? AppConfig.rabbitMQDefaultPort
        rabbitMQUser = Environment.get("RABBITMQ_USERNAME") ?? "guest"
        rabbitMQPassword = Environment.get("RABBITMQ_PASSWORD") ?? "guest"
    }
}
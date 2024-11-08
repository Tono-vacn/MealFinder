import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import SotoS3
import Redis
import RabbitMq

// configures your application
public func configure(_ app: Application) async throws {
    let _ = AppConfig.shared
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(CORSMiddleware(configuration: .default()))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: AppConfig.shared.postgresHostName,
        port: AppConfig.shared.postgresPort,
        username: AppConfig.shared.postgresUsername,
        password: AppConfig.shared.postgresPassword,
        database: AppConfig.shared.postgresDatabase,
        // tls: .prefer(try .init(configuration: .clientDefault))
        tlsConfiguration: .forClient(certificateVerification: .none)
        )
    ), as: .psql)


    let awsClient = AWSClient(
        credentialProvider: .static(accessKeyId: AppConfig.shared.awsAccessKeyID,
                                     secretAccessKey: AppConfig.shared.awsSecretAccessKey),
                                     httpClientProvider: .shared(app.http.client.shared)
    )
    app.aws.client = awsClient

    let s3 = S3(client: awsClient, region: .useast2)

    app.aws.s3 = s3

    app.redis.configuration = try RedisConfiguration(
        hostname: AppConfig.shared.redisHostName,
        port: AppConfig.shared.redisPort,
        password: AppConfig.shared.redisPassword
    )


    app.lifecycle.use(ShutdownAWSClient(awsClient: awsClient))

    // let mqConnection = RabbitMq.BasicConnection(AppConfig.shared.rabbitMQUrl)

    app.rabbitMQ.connection = RabbitMq.BasicConnection(AppConfig.shared.rabbitMQUrl)

    try await app.rabbitMQ.connection.connect()

    app.rabbitMQ.publisher = Publisher(app.rabbitMQ.connection, "MealFinderExchange")

    // app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateRecipe())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())
    app.migrations.add(CreatePostUserLike())
    app.migrations.add(CreateCommentUserLike())
    app.migrations.add(CreatePostUserDislike())
    app.migrations.add(CreateCommentUserDislike())

    // register routes
    try routes(app)
}

// Helper to shutdown AWS client
struct ShutdownAWSClient: LifecycleHandler {
    let awsClient: AWSClient
    
    func shutdown(_ application: Application) throws {
        try awsClient.syncShutdown()
    }
}

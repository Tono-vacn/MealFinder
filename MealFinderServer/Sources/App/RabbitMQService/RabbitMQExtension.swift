import RabbitMq
import Vapor

extension Application {
    var rabbitMQ: RabbitMQ {
        .init(application: self)
    }

    struct RabbitMQ {
        struct ConnectionKey: StorageKey {
            typealias Value = BasicConnection
        }

        struct RetryingConnectionKey: StorageKey {
            typealias Value = RetryingConnection
        }

        struct PublisherKey: StorageKey {
            typealias Value = Publisher
        }

        public var connection: BasicConnection {
            get {
                guard let connection = self.application.storage[ConnectionKey.self] else {
                    fatalError("RabbitMQ connection not setup. Use application.rabbitMQ.connection = ...")
                }
                return connection
            }
            nonmutating set {
                self.application.storage.set(ConnectionKey.self, to: newValue) { connection in 
                    Task {
                      await connection.close()
                    }
                }
            }
        }

        public var retryingConnection: RetryingConnection {
            get {
                guard let retryingConnection = self.application.storage[RetryingConnectionKey.self] else {
                    fatalError("RabbitMQ retrying connection not setup. Use application.rabbitMQ.retryingConnection = ...")
                }
                return retryingConnection
            }
            nonmutating set {
                self.application.storage.set(RetryingConnectionKey.self, to: newValue) { 
                    retryingConnection in 
                    // Task {
                    //   await retryingConnection.close()
                    // }
                }
            }
        }

        public var publisher: Publisher {
            get {
                guard let publisher = self.application.storage[PublisherKey.self] else {
                    fatalError("RabbitMQ publisher not setup. Use application.rabbitMQ.publisher = ...")
                }
                return publisher
            }
            nonmutating set {
                self.application.storage[PublisherKey.self] = newValue
            }
        }

        let application: Application
    }
}

public extension Request {
    var rabbitMQ: RabbitMQ {
        .init(request: self)
    }

    struct RabbitMQ {
        var connection: BasicConnection {
            return request.application.rabbitMQ.connection
        }

        var retryingConnection: RetryingConnection {
            return request.application.rabbitMQ.retryingConnection
        }

        var publisher: Publisher {
            return request.application.rabbitMQ.publisher
        }

        let request: Request
    }
}
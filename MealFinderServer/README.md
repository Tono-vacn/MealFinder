# MealFinder Web Server

This is the web server for the MealFinder project. It is a RESTful API that provides access to the MealFinder database.

- This project is written in Swift
- Web Framework: Vapor
- Database: PostgreSQL
- ORM: Fluent
- MessageQueue: RabbitMQ
- Cache: Redis
- Image Storage: AWS S3

## Installation
Ensure you have all the required services set up:
- PostgreSQL
- RabbitMQ
- Redis
- AWS S3

Add your `.env` file to the root of the project.

Use the Swift Package Manager, run the following command to install the dependencies and start the server:
```bash
swift run App
```


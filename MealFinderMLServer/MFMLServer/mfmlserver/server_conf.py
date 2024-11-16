from dotenv import load_dotenv
import os

class ServerConfig:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ServerConfig, cls).__new__(cls)
        return cls._instance
      
    def __init__(self):
        load_dotenv()
        self.redis_host = os.getenv('REDIS_HOST')
        self.redis_port = int(os.getenv('REDIS_PORT'))
        self.redis_psw = os.getenv('REDIS_PASSWORD')

        self.s3_access_key = os.getenv('AWS_ACCESS_KEY_ID')
        self.s3_secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')

        self.rabbitmq_host = os.getenv('RABBITMQ_HOST')
        self.rabbitmq_port = int(os.getenv('RABBITMQ_PORT'))
        self.rabbitmq_user = os.getenv('RABBITMQ_USERNAME')
        self.rabbitmq_psw = os.getenv('RABBITMQ_PASSWORD')

        self.openai_api_key = os.getenv('OPENAI_API_KEY')

# redis_host = os.getenv('REDIS_HOST')
# redis_port = int(os.getenv('REDIS_PORT'))
# redis_psw = os.getenv('REDIS_PASSWORD')

# s3_access_key = os.getenv('AWS_ACCESS_KEY_ID')
# s3_secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')

# rabbitmq_host = os.getenv('RABBITMQ_HOST')
# rabbitmq_port = int(os.getenv('RABBITMQ_PORT'))
# rabbitmq_user = os.getenv('RABBITMQ_USERNAME')
# rabbitmq_psw = os.getenv('RABBITMQ_PASSWORD')

# openai_api_key = os.getenv('OPENAI_API_KEY')
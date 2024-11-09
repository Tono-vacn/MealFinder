import pika
import json
import redis
import boto3
from dotenv import load_dotenv
import os

load_dotenv()

redis_host = os.getenv('REDIS_HOST')
redis_port = int(os.getenv('REDIS_PORT'))
redis_psw = os.getenv('REDIS_PASSWORD')

s3_access_key = os.getenv('AWS_ACCESS_KEY_ID')
s3_secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')

rabbitmq_host = os.getenv('RABBITMQ_HOST')
rabbitmq_port = int(os.getenv('RABBITMQ_PORT'))
rabbitmq_user = os.getenv('RABBITMQ_USERNAME')
rabbitmq_psw = os.getenv('RABBITMQ_PASSWORD')

redis_client = redis.Redis(host=redis_host, port=redis_port, db=0, password=redis_psw)   
s3 = boto3.client(service_name='s3', region_name='us-east-2', aws_access_key_id=s3_access_key, aws_secret_access_key=s3_secret_key)

def fetch_and_process(ch, method, properties, body):
    print(" [x] Received %r" % body)
    data = json.loads(body)
    task_id = data['taskID']
    key_val = data['key']
    url_val = data['url']
    
    # Fetch the image from the S3 bucket
    obj = s3.get_object(Bucket='MealFinderBucket', Key=key_val)
    # transform the object to an image as PNG
    imageData = obj['Body']
    
    
    # input the image to the model
    
    # output the result
    
    
    
    redis_client.set(task_id, url_val)
    
def main():
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=rabbitmq_host, port=rabbitmq_port, credentials=pika.PlainCredentials(rabbitmq_user, rabbitmq_psw)))
    channel = connection.channel()

    channel.exchange_declare(exchange='MealFinderExchange', exchange_type='fanout')
    channel.queue_declare(queue='task_queue', durable=True)
    channel.queue_bind(exchange='MealFinderExchange', queue='task_queue', routing_key='task')
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue='task_queue', on_message_callback=fetch_and_process)

    print(' [*] Waiting for messages. To exit press CTRL+C')
    channel.start_consuming()  
  
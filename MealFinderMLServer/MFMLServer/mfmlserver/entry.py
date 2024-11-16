import pika
import json
import redis
import boto3
from server_conf import ServerConfig
# from agent import create_image_task_with_url
from agent import process_task_with_url

Config = ServerConfig()

redis_client = redis.Redis(host=Config.redis_host, port=Config.redis_port, db=0, password=Config.redis_psw)   
s3 = boto3.client(service_name='s3', region_name='us-east-2', aws_access_key_id=Config.s3_access_key, aws_secret_access_key=Config.s3_secret_key)

def fetch_and_process(ch, method, properties, body):
    try:
        print(" [x] Received %r" % body)
        data = json.loads(body)
        task_id = data['taskID']
        # key_val = data['key']
        url_val = data['url']
        
        # Fetch the image from the S3 bucket
        # obj = s3.get_object(Bucket='mealfinderbucket', Key=key_val)
        # transform the object to an image as PNG
        # imageData = obj['Body']
        # print(url_val)
        res = process_task_with_url(url_val)
        
        # print(imageData)
        redis_client.set(task_id, res)
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as e:
        print(e)
        redis_client.set(task_id, f"error: {e}")
        ch.basic_ack(delivery_tag=method.delivery_tag)
    
    
    # redis_client.set(task_id, url_val)
    
def main():
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=Config.rabbitmq_host, port=Config.rabbitmq_port, credentials=pika.PlainCredentials(Config.rabbitmq_user, Config.rabbitmq_psw)))
    channel = connection.channel()

    channel.exchange_declare(exchange='MealFinderExchange', exchange_type='direct')
    channel.queue_declare(queue='task_queue', durable=True)
    channel.queue_bind(exchange='MealFinderExchange', queue='task_queue', routing_key='task')
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue='task_queue', on_message_callback=fetch_and_process)

    print(' [*] Waiting for messages. To exit press CTRL+C')
    channel.start_consuming()  
    
if __name__ == '__main__':
    main()
  
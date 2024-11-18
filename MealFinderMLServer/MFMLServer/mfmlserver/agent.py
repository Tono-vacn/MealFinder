import openai

from server_conf import ServerConfig

Config = ServerConfig()

openai.api_key = Config.openai_api_key

client = openai.OpenAI()

assistant = client.beta.assistants.create(
  name = "MealFinderAssistant",
  instructions = "You are a professional food ingredient inspector. You are tasked with identifying the ingredients in a food image. You are provided with an image and you need to identify the food ingredients' name in the image. Your response should only be a list of ingredients names, separated by commas, like 'ingredient1, ingredient2, ingredient3'. If there is no food ingredients in the image or you failed to identify the ingredients, please add 'error: ' at the beginning of your response.",
  model="gpt-4o-mini",
)



def process_task_with_url(url:str) -> str:
  thread = client.beta.threads.create()
  client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content=[{
      "type": "image_url",
      "image_url": {
        "url": url
      }
    }]
  )
  run = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
  )
  if run.status == "completed":
    messages = client.beta.threads.messages.list(
      thread_id=thread.id
    )
    return messages.data[0].content[0].text.value
  else:
    print("Task processing failed")
    print(run.status)
    messages = client.beta.threads.messages.list(
      thread_id=thread.id
    )
    return messages.data[0].content[0].text.value

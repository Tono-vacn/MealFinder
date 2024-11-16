from agent import process_task_with_url

def test_task_process():
  print("[*] Testing task processing")
  print(process_task_with_url("http://MealFinderBucket.s3.amazonaws.com/2E5FBE1A-A1A4-49ED-82FF-161E93A92668.jpeg"))

def main():
  test_task_process()
    
if __name__ == '__main__':
    main()
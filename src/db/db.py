import os
import psycopg2

def load_config():
  return {
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT'),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
  }

def connect(config=None):
  if config is None:
    config = load_config()

  print(f"Connecting to database at {config['host']}...")

  conn = psycopg2.connect(**config)

  print("Successfully connected")
  return conn
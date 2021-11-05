import argparse
from datetime import datetime, timedelta
from db.db import connect
from dotenv import load_dotenv
import random
import uuid

load_dotenv('.env.shared')
load_dotenv()

random.seed("a consistent but unpredictable source of noise")

# Make up some fake ISO alpha-3 codes
COUNTRY_RISKS = {
  'AAA': 'low',
  'BBB': 'low',
  'CCC': 'medium',
  'DDD': 'medium',
  'EEE': 'medium',
  'FFF': 'medium',
  'GGG': 'high',
  'HHH': 'high',
}

RISK_THRESHOLDS = {
  'low': 45_000,
  'medium': 30_000,
  'high': 10_000,
}

def populate_risk_tables(cursor):
  cursor.execute('DELETE FROM country_risks;')
  cursor.execute('DELETE FROM risk_thresholds;')

  for country in COUNTRY_RISKS:
    cursor.execute('INSERT INTO country_risks (country, risk_level) VALUES (%s, %s);', (country, COUNTRY_RISKS[country]))

  for level in RISK_THRESHOLDS:
    cursor.execute('INSERT INTO risk_thresholds (risk_level, volume_threshold_usd) VALUES (%s, %s);', (level, RISK_THRESHOLDS[level]))

RECIPIENT_COUNT_DISTRIBUTION = [1] * 10 + [2] * 15 + [3] * 8 + [4] * 3 + list(range(5, 31))

def create_sender():
  recipients = []
  for i in range(random.choice(RECIPIENT_COUNT_DISTRIBUTION)):
    recipients.append({
      'id': str(uuid.uuid4()),
      'country': random.choice(list(COUNTRY_RISKS.keys())),
    })
  return {
    'id': str(uuid.uuid4()),
    'age_days': random.randint(65, 1000),
    'send_cadence_days': random.randint(6, 60),
    'recipients': recipients,
    'trust_level': random.choice([None] + list(range(2, 6)))
  }

def create_transactions(sender):
  txns = []
  date = datetime.today() - timedelta(days=sender['age_days'])
  while date < datetime.today():
    rec = random.choice(sender['recipients'])
    txns.append({
      'id': str(uuid.uuid4()),
      'sender_id': sender['id'],
      'recipient_id': rec['id'],
      'receive_country': rec['country'],
      'amount_usd': random.randint(100, 3000),
      'complete_timestamp': (date + timedelta(minutes=random.randint(0, 1440))).strftime('%Y-%m-%dT%H:%M:%SZ')
    })
    date += timedelta(days=sender['send_cadence_days'])

  return txns

def populate_sender_trust_level(cursor, sender_id, level):
  if level != None:
    cursor.execute('INSERT INTO participant_trust_levels (id, trust_level) VALUES (%s, %s)', (sender_id, level))

def populate_transactions(cursor, transactions):
  for txn in transactions:
    cursor.execute('INSERT INTO raw_transactions (id, sender_id, recipient_id, amount_usd, receive_country, complete_timestamp) VALUES (%s, %s, %s, %s, %s, %s)', (txn['id'], txn['sender_id'], txn['recipient_id'], txn['amount_usd'], txn['receive_country'], txn['complete_timestamp']))

def main(args):
  start_time = datetime.now()
  conn = connect()

  cursor = conn.cursor()

  print(f'Populating risk tables...')
  populate_risk_tables(cursor)

  sender_count = args.senders
  print(f'Populating database with txns for {sender_count} senders...')

  txn_count = 0
  for i in range(sender_count):
    snd = create_sender()
    populate_sender_trust_level(cursor, snd['id'], snd['trust_level'])

    txns = create_transactions(snd)
    populate_transactions(cursor, txns)
    txn_count += len(txns)
  
  conn.commit()

  end_time = datetime.now()
  duration = end_time - start_time
  print(f'Created {txn_count} transactions for {sender_count} senders in {duration.total_seconds()} seconds')

def get_cli_args():
  parser = argparse.ArgumentParser(description='Populate database with test data.')
  parser.add_argument('--senders', type=int, default=20, help='number of senders to generate')
  return parser.parse_args()

if __name__ == '__main__':
  args = get_cli_args()
  main(args)
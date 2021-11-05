-- Add raw data tables
-- depends: 

-- This is the postgres eqivalent of MySQL's ON UPDATE CURRENT_TIMESTAMP
-- https://stackoverflow.com/questions/1035980/update-timestamp-when-row-is-updated-in-postgresql
CREATE OR REPLACE FUNCTION set_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TABLE raw_transactions (
  -- All IDs are UUIDs, which are guaranteed 36 characters long
  -- Since lengths are fixed, don't bother with VARCHAR
  id CHAR(36) NOT NULL PRIMARY KEY,
  recipient_id CHAR(36) NOT NULL,
  sender_id CHAR(36) NOT NULL,

  -- Note that units are clearly labeled
  amount_usd INT NOT NULL,

  -- 3-character ISO country code
  receive_country CHAR(3) NOT NULL,

  -- Fun fact: in MySQL, TIMESTAMP is a 4-byte time and suffers from the 2038 problem
  -- you should use the 8-byte DATETIME instead. In Postgres, DATETIME does not exist
  -- and TIMESTAMP is 8 bytes.
  -- complete_timestamp is domain data (when the txn completed)
  complete_timestamp TIMESTAMP(3) NOT NULL,

  -- created and updated are when the row was created / modified
  created TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
  updated TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);

CREATE TRIGGER set_raw_transactions_update_time BEFORE UPDATE
ON raw_transactions FOR EACH ROW EXECUTE PROCEDURE 
set_update_timestamp();

-- postgres lets you define a custom enum type
-- mysql doesn't support this, enums can only be defined in-line in a table definintion
-- you can either copy/pase the enum everywhere it's needed, or create a table to
-- represent it and use foreign-key constraints to enforce correctness
CREATE TYPE risk AS ENUM ('low', 'medium', 'high');

CREATE TABLE risk_thresholds (
  -- Auto-incrementing ID
  -- Note BIGSERIAL instead of SERIAL. SERIAL would probably be fine for this application,
  -- but 4 billion unique records is less than you think (this caused an outage at Remitly once)
  id BIGSERIAL NOT NULL PRIMARY KEY,

  risk_level risk NOT NULL,
  volume_threshold_usd INT NOT NULL,
  created TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);

CREATE TABLE country_risks (
  id BIGSERIAL NOT NULL PRIMARY KEY,

  country CHAR(3) NOT NULL,
  risk_level risk NOT NULL,
  created TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);

CREATE TABLE participant_trust_levels (
  id CHAR(36) NOT NULL PRIMARY KEY,
  trust_level INT NOT NULL DEFAULT 1,
  created TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
  updated TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);

CREATE TRIGGER set_participant_trust_levels_update_time BEFORE UPDATE
ON participant_trust_levels FOR EACH ROW EXECUTE PROCEDURE 
set_update_timestamp();
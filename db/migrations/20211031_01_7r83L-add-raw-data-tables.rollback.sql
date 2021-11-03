DROP TABLE IF EXISTS country_risks;
DROP TABLE IF EXISTS risk_thresholds;
DROP TABLE IF EXISTS risk_levels;

DROP TRIGGER IF EXISTS set_raw_transactions_update_time ON raw_transactions;
DROP TABLE IF EXISTS raw_transactions;

DROP FUNCTION IF EXISTS set_update_timestamp();